select c.name                            as category_name,
       monthname(p.date)                 as month_name,
       sum(pi.amount * pi.inorder_price) as total_sales
from purchase p
         join
     purchase_items pi on p.id = pi.purchase_id
         join
     product pr on pi.product_id = pr.id
         join
     category c on pr.category_code = c.code
where year(p.date) = year(curdate()) - 1
group by c.name, year(p.date), month_name
order by month_name;