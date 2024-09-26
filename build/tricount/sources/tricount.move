/// Module: tricount
module tricount::tricount {
    use sui::table::{Table, Self};
    use std::vector;

    public struct Count has key, store {
        id: UID,
        total: u64,
        people: Table<address, u64>
    }

    public entry fun new(ctx: &mut TxContext){
        let unit: Count = Count {
            id: object::new(ctx),
            total: 0,
            people: table::new<address, u64>(ctx)
        };
        transfer::share_object(unit);
    }

    public entry fun balance(ctx: &mut TxContext){

    }

    public entry fun addMoney(tri: &mut Count, amount: u64, mut nameConsumer: vector<address>, ctx: &mut TxContext): bool{
        if (amount > 0) {
            tri.total = tri.total + amount;
            let balance_provi = table::borrow_mut(&mut tri.people, tx_context::sender(ctx));
            *balance_provi = *balance_provi + amount;
            //let lenght = vector::lenght();
            while (!vector::is_empty(&nameConsumer)){
                let balance_cons = table::borrow_mut(&mut tri.people, vector::pop_back(&mut nameConsumer));
                *balance_cons = *balance_cons + amount;
            };
            return true
        } else {
            return false
        }
    }

    public entry fun total(tri: &mut Count, ctx: &mut TxContext): u64{
        tri.total
    }
}
 