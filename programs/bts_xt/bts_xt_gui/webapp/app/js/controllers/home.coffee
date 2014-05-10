angular.module("app").controller "HomeController", ($scope, $modal, $log, RpcService) ->
  $scope.transactions = []

  $scope.balance = 0.0

#  RpcService.request('current_wallet').then (response) ->
#    console.log '--- current_wallet', response
#    if response.result == null
#      console.log "no current_wallet, please open wallet"
#      #$scope.open_wallet()

  # TODO: move transaction loading into Angular's service,
  # it should be able to cache transactions and update the cache when updates detected
  # also it should sort transactions by trx_num desc
  fromat_address = (addr) ->
    return "-" if !addr or addr.length == 0
    res = ""
    angular.forEach addr, (a) ->
      res += ", " if res.length > 0
      res += a[1]
    res
  format_amount = (delta_balance) ->
    return "-" if !delta_balance or delta_balance.length == 0
    first_asset = delta_balance[0]
    return "-" if !first_asset or first_asset.length < 2
    first_asset[1]

  RpcService.request('getbalance').then (response) ->
    console.log "balance: ", response.result.amount
    $scope.balance = response.result.amount

  $scope.load_transactions = ->
    RpcService.request("rescan").then (response) ->
      RpcService.request("get_transaction_history").then (response) ->
        $scope.transactions.splice(0, $scope.transactions.length)
        count = 0
        angular.forEach response.result, (val) ->
          count += 1
          if count < 10
            $scope.transactions.push
              block_num: val.block_num
              trx_num: val.trx_num
              time: val.confirm_time
              amount: format_amount(val.delta_balance)
              from: fromat_address(val.from)
              to: fromat_address(val.to)
              memo: val.memo

  $scope.load_transactions()
