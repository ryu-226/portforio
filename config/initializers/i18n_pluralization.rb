# 日本語の pluralization ルールを明示的に設定（YAMLでの記述を避けるため）
I18n.backend.store_translations(:ja, i18n: {
  plural: {
    keys: [:zero, :one, :other],
    rule: lambda { |n|
      if n == 0
        :zero
      elsif n == 1
        :one
      else
        :other
      end
    }
  }
})