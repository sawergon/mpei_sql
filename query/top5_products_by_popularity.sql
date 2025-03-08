select product.name as name,
    sum(purchase_items.amount) as amount
from product
join purchase_items on product.id = purchase_items.product_id
group by name
order by amount desc
limit 5;