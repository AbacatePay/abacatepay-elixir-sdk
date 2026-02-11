Mimic.copy(AbacatePay.HTTPClient)

ExUnit.configure(exclude: [disabled: true])
ExUnit.start()

Application.ensure_all_started(:bypass)
