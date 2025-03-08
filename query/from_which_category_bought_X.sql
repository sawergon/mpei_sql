select category.name
from customer
         join purchase on customer.id = purchase.customer_id
         join purchase_items on purchase.id = purchase_items.purchase_id
         join product on product.id = purchase_items.product_id
         join category on category.code = product.category_code
where customer.name = 'иван иванов'
group by category.name;