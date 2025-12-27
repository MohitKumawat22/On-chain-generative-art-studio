module wallet_address::GenerativeArtStudio {
 
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
 
    /// Struct representing a generative art NFT.
    struct GenerativeNFT has store, key {
        token_id: u64,           // Unique identifier for the NFT
        seed: u64,               // Random seed generated at mint time
        mint_timestamp: u64,     // Timestamp when NFT was minted
        owner: address,          // Current owner of the NFT
    }
 
    /// Struct to track the studio's minting statistics.
    struct StudioData has store, key {
        total_minted: u64,       // Total number of NFTs minted
        mint_price: u64,         // Price to mint an NFT
    }
 
    /// Initialize the generative art studio with a mint price.
    public fun initialize_studio(creator: &signer, mint_price: u64) {
        let studio_data = StudioData {
            total_minted: 0,
            mint_price,
        };
        move_to(creator, studio_data);
    }
 
    /// Mint a new generative art NFT with randomness.
    public fun mint_nft(minter: &signer, studio_owner: address) acquires StudioData {
        let studio = borrow_global_mut<StudioData>(studio_owner);
        let minter_addr = signer::address_of(minter);
        
        // Collect mint price from minter
        let payment = coin::withdraw<AptosCoin>(minter, studio.mint_price);
        coin::deposit<AptosCoin>(studio_owner, payment);
        
        // Generate pseudo-random seed using timestamp and token count
        let current_time = timestamp::now_microseconds();
        let seed = current_time + studio.total_minted;
        
        // Create NFT with generated randomness
        let nft = GenerativeNFT {
            token_id: studio.total_minted + 1,
            seed,
            mint_timestamp: current_time,
            owner: minter_addr,
        };
        
        // Update minting statistics
        studio.total_minted = studio.total_minted + 1;
        
        // Transfer NFT to minter
        move_to(minter, nft);
    }
}