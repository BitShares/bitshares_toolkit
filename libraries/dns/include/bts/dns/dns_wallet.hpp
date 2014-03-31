#pragma once

#include <bts/dns/dns_util.hpp>

namespace bts { namespace dns {

using namespace bts::blockchain;
using namespace bts::wallet;

class dns_wallet : public bts::wallet::wallet
{
    public:
        dns_wallet();
        ~dns_wallet();

        signed_transaction bid_on_domain(const std::string &name, const asset &bid_price,
                                         const signed_transactions &tx_pool, dns_db &db);

        signed_transaction update_domain_record(const std::string &name, const fc::variant &value,
                                                const signed_transactions &tx_pool, dns_db &db);

        signed_transaction auction_domain(const std::string &name, const asset &ask_price,
                                          const signed_transactions &tx_pool, dns_db &db);

        // TODO put this in the parent wallet class?
        signed_transaction add_fee_and_sign(signed_transaction &trx, asset required_in, asset& total_in,
                                            std::unordered_set<address> req_sigs);

    protected:
        signed_transaction update_or_auction_domain(bool update, claim_domain_output &domain_output, asset amount,
                                                    const signed_transactions &tx_pool, dns_db &db);

        virtual bool scan_output(transaction_state& state, const trx_output& out, const output_reference& ref,
                                 const output_index& idx);
 };

}} // bts::dns 
