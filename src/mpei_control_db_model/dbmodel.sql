create table category
(
    code int          not null
        primary key,
    name varchar(255) null
);

create table customer
(
    id   int auto_increment
        primary key,
    name varchar(255) not null
);

create table product
(
    id            int auto_increment
        primary key,
    name          varchar(255) null,
    price         double default 0.0,
    category_code int          null,
    constraint product_category_code_fk
        foreign key (category_code) references category (code) on delete cascade
);

create table purchase
(
    id          int auto_increment
        primary key,
    date        datetime null,
    price       double default 0.0,
    customer_id int      null,
    constraint purchase_customer_id_fk
        foreign key (customer_id) references customer (id) on delete cascade
);

create table purchase_items
(
    amount        int default 0,
    product_id    int null,
    purchase_id   int null,
    inorder_price double default 0.0 comment 'product price in time where it was bought',
    constraint purchase_items_product_id_fk
        foreign key (product_id) references product (id) on delete cascade,
    constraint purchase_items_purchase_id_fk
        foreign key (purchase_id) references purchase (id) on delete cascade
);

