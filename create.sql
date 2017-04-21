create table if not exists accounts (
	account_id integer primary key,
	account_name text not null,
	account_balance integer default 0
);

create table if not exists transactions (
	transaction_id integer primary key,
	transaction_amount integer not null,
	transaction_label text,
	transaction_source integer references accounts (account_id),
	transaction_destination integer references accounts (account_id),
	transaction_datetime integer
	check(transaction_source != 1000 and transaction_destination != 1000)
	check(transaction_source != transaction_destination)
);

insert into accounts (account_id, account_name, account_balance)
	values (1000, "Reserves", 0);
insert into accounts (account_id, account_name, account_balance)
	values (1001, "Capital", 0);

create trigger transaction_auto_datetime after insert on transactions
	for each row
	when new.transaction_datetime isnull
begin
	update transactions
		set transaction_datetime = datetime("now")
		where transaction_id = new.transaction_id;
end;

create trigger transaction_update_destination after insert on transactions
	for each row
	when new.transaction_destination not null
begin
	update accounts
		set account_balance = account_balance + new.transaction_amount
		where account_id = new.transaction_destination;
end;

create trigger transaction_update_source after insert on transactions
	for each row
	when new.transaction_source not null 
begin
	update accounts
		set account_balance = account_balance - new.transaction_amount
		where account_id = new.transaction_source;
end;

create trigger transaction_update_in after insert on transactions
	for each row
	when new.transaction_source isnull
begin
	update accounts
		set account_balance = account_balance + new.transaction_amount
		where account_id = 1000;
end;

create trigger transaction_update_out after insert on transactions
	for each row
	when new.transaction_destination isnull
begin
	update accounts
		set account_balance = account_balance - new.transaction_amount
		where account_id = 1000;
end;

