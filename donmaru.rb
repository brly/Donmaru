require 'cinch'
require 'nokogiri'
require 'open-uri'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick            = "donmaru"

    #弊社のircサーバー名を記入
    c.server          = ""
    c.channels        = ["#丼丸"]
    #c.channels        = ["#artifata"]
  end end

bot.on :message, /^donmaru: ?大盛り/ do |m|
    m.reply "ご飯大盛りは648円（税込）だどん"
end

bot.on :message, /^donmaru: ?ネタ大盛り/ do |m|
    m.reply "ネタ大盛りは756円（税込）だどん"
end

bot.on :message, /^donmaru: ?特盛り/ do |m|
    m.reply "特盛りは864円（税込）だどん"
end

bot.on :message, /^donmaru: 今日は何丼\？/ do |m|
    rand = [*1..83].sample

    if rand == 83 then
        m.reply "#{m.user.nick}は今日は松屋にしとけ(プレミアム牛肉)"
    else
        url = "http://donmaru.kyu-mu.net/items/#{rand}"
        charset = nil
        html = open(url) do |f|
            charset = f.charset
            f.read
        end

        doc = Nokogiri::HTML.parse(html, nil, charset)

        netaStr = ""

        doc.xpath("//span[@class='nowrap']").each do |node|
            netaStr << node.text
        end

        imgURL = "http://donmaru.kyu-mu.net/img/don/menu#{rand}.jpg"

        luckeyDon = doc.xpath("//html/body/div/div/h2").text
        if rand == 29 then
            m.reply "#{m.user.nick}にはうんこ丼(うんこ)がおすすめ,#{imgURL}"
        else
            m.reply "#{m.user.nick}の今日のラッキー丼は#{luckeyDon}(#{netaStr}),#{imgURL}"
        end
    end
end

bot.on :message, /^donmaru: 0のつく日は/ do |m|
    m.reply "500円になるどん!!!"
end

bot.on :message, /^donmaru: .+丼はおいしい.*？$/ do |m|
    num = [*1..4].sample
    if num == 1 then
        m.reply "あてはまる"
    elsif num == 2 then
        m.reply "まああてはまる"
    elsif num == 3 then
        m.reply "少しあてはまる"
    else
        m.reply "あてはまらない"
    end
end

bot.start
