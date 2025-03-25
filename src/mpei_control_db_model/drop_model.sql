drop table if exists purchase_items;
drop table if exists purchase;
drop table if exists stock;
drop table if exists product;
drop table if exists customer;
drop table if exists category;

drop procedure if exists add_product;
drop function if exists calculate_category_total;
drop function if exists get_customer_purchase_total;
drop procedure if exists make_purchase;
drop trigger if exists prevent_category_deletion;
drop trigger if exists set_product_price_on_cart_insert;