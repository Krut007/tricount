/// Module: tricount
module tricount::tricount {
    use sui::table::{Table, Self};
    use std::vector;
    use sui::event;
    use std::string::{utf8, String};
    use sui::display;
    use sui::package;

    public struct MyEvent has copy, drop, store {}

    public struct Rat has key, store {
        id: UID,
        name: String
    }

    public struct TRICOUNT has drop {}

    public struct Vault has key, store {
        id: UID,
        total: u64,
        people: Table<address, u64>,
        spendingList: vector<Spend>,
        des: String,
        listOfPeople: vector<address>
    }

    public struct Spend has store {
        value: u64,
        provider: address,
        consumer: vector<address>
    }

    public entry fun new(name: String, mut participantList: vector<address>, ctx: &mut TxContext){
        let mut tablePeople = table::new<address, u64>(ctx);
        while (!vector::is_empty(&participantList)){
            table::add(&mut tablePeople, vector::pop_back(&mut participantList), 0);
        };
        let unit: Vault = Vault {
            id: object::new(ctx),
            total: 0,
            people: tablePeople,
            spendingList: vector::empty<Spend>(),
            des: name,
            listOfPeople: participantList
        };    
        transfer::share_object(unit);
    }

    fun init(otw: TRICOUNT, ctx: &mut TxContext){
        let keys = vector[
            utf8(b"name"),
            utf8(b"image_url"),
            utf8(b"description"),
        ];
        let values = vector[
            utf8(b"The Rats"),
            utf8(b"https://w7.pngwing.com/pngs/771/131/png-transparent-ratatouille-hollywood-ratatouille-film-pixar-the-walt-disney-company-rat-mammal-animals-cooking-thumbnail.png"),
            utf8(b"The biggest rats of : {name}")
        ];

        let publisher = package::claim(otw, ctx);

        let mut display = display::new_with_fields<Rat>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public entry fun bigRat(tri: &mut Vault, ctx: &mut TxContext){
        let triName = tri.des;
        let balance = &tri.people;
        let name = &mut tri.listOfPeople;
        let mut last: address = tx_context::sender(ctx);
        let mut min = 0;
        let mut i = 0;
        while(i != table::length(balance)){
            let unitName = vector::borrow(name, i);
            let unitBalance = table::borrow(balance, *unitName);
            if (*unitBalance < min){
                min = *unitBalance;
                last = *unitName;
            };
            i = i + 1;
        };
        if (min != 0){
            let id = object::new(ctx);
        let rat = Rat {
            id: id,
            name: triName 
        };

        transfer::public_transfer(rat, last);
        }
    }

    public entry fun balance(tri: &mut Vault, adr: address ,ctx: &mut TxContext): u64{
        let bal = table::borrow(&tri.people, adr);
        return *bal
    }

    public entry fun addMoney(tri: &mut Vault, amount: u64, mut nameConsumer: vector<address>, ctx: &mut TxContext): bool{
        if (amount > 0) {
            tri.total = tri.total + amount;
            let littleAmount = amount / (vector::length(&nameConsumer) + 1);
            let balance_provi = table::borrow_mut(&mut tri.people, tx_context::sender(ctx));
            *balance_provi = *balance_provi + (littleAmount * vector::length(&nameConsumer));
            while (!vector::is_empty(&nameConsumer)){
                let balance_cons = table::borrow_mut(&mut tri.people, vector::pop_back(&mut nameConsumer)); 
                *balance_cons = *balance_cons + littleAmount;
            };
            let spend: Spend = Spend {
                value: amount,
                provider: tx_context::sender(ctx),
                consumer: nameConsumer
            };
            let list = &mut tri.spendingList;
            vector::push_back(list, spend);
            let newSpend: MyEvent = MyEvent{};
            event::emit(newSpend);
            return true
        } else {
            return false
        }
    }

    public entry fun total(tri: &mut Vault, ctx: &mut TxContext): u64{
        tri.total
    }
}