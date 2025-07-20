class GachaDrawService
  # 帯域均等＆10円単位＆予算ピッタリで金額リスト生成
  def self.generate(min, max, days)
    amounts = []
    range = max - min
    twenty = (range * 0.2).round
    low_max = min + twenty
    high_min = max - twenty + 1

    low_days = days / 3
    high_days = days / 3
    mid_days = days - low_days - high_days

    low_days.times { amounts << rand(min..low_max).div(10) * 10 }
    mid_days.times { amounts << rand((low_max + 1)..(high_min - 1)).div(10) * 10 }
    high_days.times { amounts << rand(high_min..max).div(10) * 10 }

    # 予算合計値の微調整
    expected = days * ((min + max) / 2.0)
    diff = amounts.sum - expected.round
    if diff != 0
      idx = rand(amounts.size)
      amounts[idx] -= diff
      amounts[idx] = [[amounts[idx], min].max, max].min
    end

    amounts.shuffle
  end
end