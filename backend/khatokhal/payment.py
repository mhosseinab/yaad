
from django.contrib.contenttypes.models import ContentType
from django.urls import reverse

from app.idpay import IDPay
from .models import Invoice, Payment, Book, Purchase, PAYMENT_STATUS, INVOICE_STATUS

app_name = 'khatokhal'
BASE_URL = 'https://khatokhal.org'

def pay(user, item, gateway='IDPay'):
    
    payment = None

    if isinstance(item, Book):
        purchase, _ = Purchase.objects.get_or_create(user=user)
        if item in purchase.books.all():
            return {'success': False, 'err': 'ALREADY_PURCHASED'}
        
        invoice = Invoice.objects.create(
            user      = user,
            item_type = ContentType.objects.get_for_model(item),
            item_id   = item.id,
            price     = item.price,
            discount  = item.get_discount(),
        )
        invoice.save()

        payment = Payment.objects.create(
            invoice = invoice,
            gateway = gateway,
            amount  = invoice.total
        )

    if payment != None:
        if gateway == 'IDPay':
            callback = BASE_URL + reverse(f'{app_name}:idpay_callback')
            idpay = IDPay()
            data, err = idpay.new(
                order_id=str(payment.uuid),
                amount=payment.amount * 10, #Toman to Rial
                phone=payment.invoice.user.mobile,
                callback=callback
            )
            if data:
                payment.tid = data.get('id')
                payment.save()
                return {'success': True, 'url': data.get('link')}
            else:
                print(err)
                payment.status = PAYMENT_STATUS.GATEWAY_ERROR
                payment.note = err.get('error_message')
                payment.save()
                return {'success': False, 'err': err}

    return {'success': False, 'err': 'not implemented'}

def verify(transaction_id:str, payment_uid: str, gateway:str = 'IDPay',**kwargs):
    try:
        payment = Payment.objects.get(uuid=payment_uid)
    except Payment.DoesNotExist:
        return {'success': False, 'err': "DoesNotExist"}
    print(payment.tid, transaction_id)
    if payment.tid != transaction_id:
        return {'success': False, 'err': "Invalid TransactionID"}
    
    if payment.status == PAYMENT_STATUS.SUCCESS:
        return {'success': False, 'err': "AlreadyProcessed"}
    
    if gateway == 'IDPay':
        idpay = IDPay()
        data, err = idpay.verify(
            id=payment.tid, 
            order_id=str(payment.uuid)
        )

        if data:
            if data.get('status') in [100, 101, 200]:

                payment.recipt = data.get('track_id')
                payment.trace = data.get('payment',{}).get('track_id')
                payment.card = data.get('payment',{}).get('card_no')
                payment.status = PAYMENT_STATUS.SUCCESS
                payment.invoice.status = INVOICE_STATUS.SUCCESS
                payment.invoice.save()
                payment.save()
                process_purchased_item(
                    user=payment.invoice.user, 
                    item=payment.invoice.item
                )
                return {'success': True}
            return {'success': False, 'err': idpay.get_status_text(data.get('status'))}
        else:
            payment.status = PAYMENT_STATUS.FAILED
            payment.note = err.get('error_message')
            payment.save()
            
            return {'success': False, 'err': err}
    
    return {'success': False, 'err': 'not implemented'}

def process_purchased_item(user, item):
    if isinstance(item, Book):
        purchase, _ = Purchase.objects.get_or_create(user=user)
        if not item in purchase.books.all():
            purchase.books.add(item)
            purchase.save()
            item.purchase_count += 1
            item.save()
