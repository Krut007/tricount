/// Module: tricount
module tricount::tricount {
    use sui::table::{Table, Self};
    use std::vector;
    use sui::event;

    public struct Vault has key, store {
        id: UID,
        total: u64,
        people: Table<address, u64>,
        spendingList: vector<Spend>
    }

    public struct Spend has store {
        value: u64,
        provider: address,
        consumer: vector<address>
    }

    public entry fun new(mut participantList: vector<address>, ctx: &mut TxContext){
        let mut tablePeople = table::new<address, u64>(ctx);
        while (!vector::is_empty(&participantList)){
            table::add(&mut tablePeople, vector::pop_back(&mut participantList), 0);
        };
        let unit: Vault = Vault {
            id: object::new(ctx),
            total: 0,
            people: tablePeople,
            spendingList: vector::empty<Spend>()
        };    
        transfer::share_object(unit);
    }

    //public entry fun addPeople(tri: &mut Count, new: address, ctx: &mut TxContext){
    //    let list = table::borrow_mut(&mut tri.people, tx_context::sender(ctx));
    //    *list = table::add(*list, new, 0);
    //}

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
            
            return true
        } else {
            return false
        }
    }

    public entry fun total(tri: &mut Vault, ctx: &mut TxContext): u64{
        tri.total
    }
}
 