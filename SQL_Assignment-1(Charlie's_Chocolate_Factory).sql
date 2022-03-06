-- SQL ASSIGNMENT 1 --

CREATE DATABASE Manufacturer;

USE Manufacturer;

CREATE TABLE Product
(
prod_id INT NOT NULL,
prod_name VARCHAR(50) NOT NULL,
quantity INT NOT NULL,
	CONSTRAINT product_pk PRIMARY KEY (prod_id)
);

CREATE TABLE Supplier
(
supp_id INT NOT NULL,
supp_name VARCHAR(50) NOT NULL,
supp_location VARCHAR(50) NOT NULL,
supp_country VARCHAR(50) NOT NULL,
is_active BIT DEFAULT 1,
	CONSTRAINT supplier_pk PRIMARY KEY (supp_id)
);

CREATE TABLE Component
(
comp_id INT NOT NULL,
cpmp_name VARCHAR(50) NOT NULL,
description VARCHAR(50) NOT NULL,
quantity_comp INT NOT NULL,
	CONSTRAINT component_pk PRIMARY KEY (comp_id)
);

CREATE TABLE Prod_Comp
(
prod_id INT NOT NULL,
comp_id INT NOT NULL,
quantity_comp INT NOT NULL,
	CONSTRAINT prod_comp_pk PRIMARY KEY (prod_id,comp_id),
	CONSTRAINT prod_comp_fk_product FOREIGN KEY (prod_id) REFERENCES Product(prod_id),
    CONSTRAINT prod_comp_fk_component FOREIGN KEY(comp_id) REFERENCES Component(comp_id)
);

CREATE TABLE Comp_Supp
(
supp_id INT NOT NULL,
comp_id INT NOT NULL,
order_date DATE NOT NULL,
quantity INT NOT NULL,
	CONSTRAINT comp_supp_pk PRIMARY KEY (supp_id,comp_id),
	CONSTRAINT comp_supp_fk_supply FOREIGN KEY (supp_id) REFERENCES Supplier(supp_id),
    CONSTRAINT comp_supp_fk_component FOREIGN KEY(comp_id) REFERENCES Component(comp_id)
);