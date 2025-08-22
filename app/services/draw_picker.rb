class DrawPicker
  # マジックナンバーを定数化 金額は10円刻みで WIDH = 幅 WEIGH = 確率
  INCREMENT = 10
  WIDTH_LOW = 0.30
  WIDTH_MID = 0.40
  WIDTH_HIGH = 0.30
  WEIGHT_LOW = 0.30
  WEIGHT_MID = 0.40
  WEIGHT_HIGH = 0.30

  # メッセージ帯境界を返すための入れ物
  BandRanges = Struct.new(
    :low_min, :low_max, :mid_min, :mid_max, :high_min, :high_max,
    keyword_init: true
  )

  # 状態初期化 rng テスト用に乱数差し替え可
  def initialize(min:, max:, remaining_days:, remaining_budget:, rng: ::Kernel)
    @min = min.to_i
    @max = max.to_i
    @remaining_days = remaining_days.to_i
    @remaining_budget = remaining_budget.to_i
    @rng = rng
  end

  # 金額を 1 回分だけ決定して返す
  def pick
    min_feasible = [@min, @remaining_budget - (@max * (@remaining_days - 1))].max
    max_feasible = [@max, @remaining_budget - (@min * (@remaining_days - 1))].min

    # 最終日は残り予算を10円刻みに切り下げ、min/max の実現可能レンジにクランプ
    if @remaining_days == 1
      amount = floor_inc(@remaining_budget)
      return amount.clamp(min_feasible, max_feasible)
    end

    min10 = ceil_inc(min_feasible)
    max10 = floor_inc(max_feasible)

    # 10円グリッドに乗らないほど狭い → 近い10円に丸めてクランプ
    if min10 > max10
      amount = round_inc(min_feasible)
      return amount.clamp(min_feasible, max_feasible)
    end

    # 3帯の幅（tick数）を決める
    ticks_total = ((max10 - min10) / INCREMENT) + 1
    low_ticks = [(ticks_total * WIDTH_LOW).floor, 1].max
    mid_ticks = [(ticks_total * WIDTH_MID).floor, 1].max
    high_ticks = ticks_total - low_ticks - mid_ticks
    if high_ticks < 1
      take = 1 - high_ticks
      reduce_mid = [take, mid_ticks - 1].min
      mid_ticks -= reduce_mid
      take -= reduce_mid
      low_ticks -= [take, low_ticks - 1].min
    end

    low_min = min10
    low_max = low_min + ((low_ticks - 1) * INCREMENT)
    mid_min = low_max + INCREMENT
    mid_max = mid_min + ((mid_ticks - 1) * INCREMENT)
    high_min = mid_max + INCREMENT
    high_max = max10

    # 確率で帯を選ぶ
    r = @rng.rand
    band =
      if r < WEIGHT_LOW
        :low
      elsif r < (WEIGHT_LOW + WEIGHT_MID)
        :mid
      else
        :high
      end

    # 選ばれた帯から金額を一様に1つ選ぶ
    range =
      case band
      when :low then (low_min <= low_max ? [low_min, low_max] : [min10, max10])
      when :mid then (mid_min <= mid_max ? [mid_min, mid_max] : [min10, max10])
      when :high then (high_min <= high_max ? [high_min, high_max] : [min10, max10])
      end

    amount = pick_from_band(*range)
    amount.clamp(min_feasible, max_feasible)
  end

  # index 用：現在設定から帯の境界を算出
  def bands
    min_feasible, max_feasible = feasible_range

    min10 = ceil_inc(min_feasible)
    max10 = floor_inc(max_feasible)

    # グリッドが無いほど狭い場合は全域同一帯
    if min10 > max10
      return BandRanges.new(
        low_min: min10,  low_max: max10,
        mid_min: min10,  mid_max: max10,
        high_min: min10, high_max: max10
      )
    end

    ticks_total = ((max10 - min10) / INCREMENT) + 1

    low_ticks  = [(ticks_total * WIDTH_LOW).floor, 1].max
    mid_ticks  = [(ticks_total * WIDTH_MID).floor, 1].max
    high_ticks =  ticks_total - low_ticks - mid_ticks
    if high_ticks < 1
      take = 1 - high_ticks
      reduce_mid = [take, mid_ticks - 1].min
      mid_ticks -= reduce_mid
      take -= reduce_mid
      low_ticks -= [take, low_ticks - 1].min
    end

    low_min  = min10
    low_max  = low_min + ((low_ticks - 1) * INCREMENT)
    mid_min  = low_max + INCREMENT
    mid_max  = mid_min + ((mid_ticks - 1) * INCREMENT)
    high_min = mid_max + INCREMENT
    high_max = max10

    BandRanges.new(
      low_min:, low_max:, mid_min:, mid_max:, high_min:, high_max:
    )
  end

  # 金額が low/mid/high のどれか判定
  def classify(amount)
    r = bands
    return :low  if amount <= r.low_max
    return :high if amount >= r.high_min

    :mid
  end

  private

  # pick/bands 共通の実現可能レンジ
  def feasible_range
    min_feasible = [@min, @remaining_budget - (@max * (@remaining_days - 1))].max
    max_feasible = [@max, @remaining_budget - (@min * (@remaining_days - 1))].min
    [min_feasible, max_feasible]
  end

  def ceil_inc(val) = ((val + INCREMENT - 1) / INCREMENT) * INCREMENT
  def floor_inc(val) = (val / INCREMENT) * INCREMENT
  def round_inc(val) = (val.to_f / INCREMENT).round * INCREMENT

  def pick_from_band(start_yen, end_yen)
    ticks = ((end_yen - start_yen) / INCREMENT) + 1
    idx = @rng.rand(ticks)
    start_yen + (idx * INCREMENT)
  end
end
