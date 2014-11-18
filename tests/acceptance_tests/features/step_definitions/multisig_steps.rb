When(/^I make multisig deposit (\d+) (\w+) from (\w+) to (\d+) of (\[.*\])$/) do |amount, symbol, from, req, addrs|
    addr_name_list = JSON.parse(addrs.gsub(/(\w+)/, '"\1"'))
    addr_list = []
    for name in addr_name_list
        addr_list << @addresses[name]
    end
    @current_actor.node.exec 'wallet_multisig_deposit', to_f(amount), symbol, get_actor(from).account, req, addr_list
end

When(/^I save multisig ID for (\d+) of (\[.*\]) as (\w+)$/) do |req, addrs, id_name|
    addr_name_list = JSON.parse(addrs.gsub(/(\w+)/, '"\1"'))
    addr_list = []
    for name in addr_name_list
        addr_list << @addresses[name]
    end
    id = @current_actor.node.exec 'wallet_multisig_get_balance_id', req, addr_list
    @addresses ||= {}
    @addresses[id_name] = id
end

When(/^I start multisig withdrawal of (\d+) (\w+) from (\w+) to (\w+) as (\w+)$/) do |amount, symbol, multi_id, addr, builder_id|
    builder = @current_actor.node.exec 'wallet_multisig_withdraw_start', to_f(amount) - 0.5, symbol, @addresses[multi_id], @addresses[addr]
    @addresses[builder_id] = builder
end

When(/^I add signature and broadcast (\w+) expecting (failure|success)$/) do |builder_id, succeed|
    builder = @addresses[builder_id]
    if succeed == "success"
        @addresses[builder_id] = @current_actor.node.exec 'wallet_builder_add_signature', builder, true
    elsif succeed == "failure"
        begin
            @current_actor.node.exec 'wallet_builder_add_signature', builder, true
        rescue
            puts "Successfully failed"
        else
            raise Error, "Expected this transaction to fail"
        end
    else
        raise Error, "Unknown option"
    end

end

Then(/^Balance with ID (\w+) should have (\d+) (\w+)$/) do |id, amount, symbol|
    bal = @current_actor.node.exec 'blockchain_get_balance', @addresses[id]
    expect(bal['balance'] == to_f(amount) / 10000)
end

Then(/^Balance with owner (\w+) should have (\d+) (\w+)$/) do |id, amount, symbol|
    bals = @current_actor.node.exec 'blockchain_list_address_balances', @addresses[id]
    expect(bals.length > 0)
    puts bals
    expect(bals[0]['balance'] == to_f(amount) / 10000)
end

Then(/^Balance with public accountname: (\w+) should have (\d+) (\w+)$/) do |id, amount, symbol|
    bals = @current_actor.node.exec 'blockchain_get_account_public_balance', id
    bal = bals[0][1][0][1] # maps as lists
    expect(bal == to_f(amount) * 10000)
end



Then(/^I'm a happy shareholder!/) do
end
