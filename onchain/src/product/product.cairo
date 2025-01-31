#[starknet::contract]
pub mod Product {
    use core::num::traits::zero::Zero;
    use core::starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use starknet::ContractAddress;
    use scanguard::interfaces::IProduct::IProducts;
    use scanguard::base::types::ProductParams;
    use scanguard::base::errors::Errors::ZERO_ADDRESS_CALLER;
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;


    #[storage]
    struct Storage {
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
        products: Map::<felt252, ByteArray>,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        assert(!owner.is_zero(), ZERO_ADDRESS_CALLER);
        self.ownable.initializer(owner);
    }

    #[abi(embed_v0)]
    impl ProductImpl of IProducts<ContractState> {
        fn verify(self: @ContractState, product_id: felt252) -> ProductParams {
            let ipfs_hash = self.products.read(product_id);

            if (ipfs_hash != "0") {
                let product = ProductParams { product_id: product_id, ipfs_hash: ipfs_hash };

                return product;
            }

            ProductParams { product_id: product_id, ipfs_hash: ipfs_hash }
        }

        fn register_product(ref self: ContractState, product_id: felt252, ipfs_hash: ByteArray) {
            self.ownable.assert_only_owner();
            self.products.write(product_id, ipfs_hash);
        }
    }
}

