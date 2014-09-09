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
  end
end

#donmaru: と話しかける前提での処理
#もっと汎用的に対応できる書き方があればプルリクを。
bot.on :message do |m|
    #「:」の前後で文字列を分ける
    message = m.message.split(/\s*:\s*/)

    if (message[0] == "donmaru") then
        case message[1]
        when /今日は何丼.*$/
            getLuckyDon(m)
        when "並盛り"
            putsRegularSizePrice(m)
        when "大盛り"
            putsLargeSizePrice(m)
        when "特盛り"
            putsSpecialSizePrice(m)
        when "ネタ大盛り"
            putsSushiMaterialLargeSizePrice(m)
        when /競合店は.*？/
            putsCompetition(m)
        when /創業者は.*？$/
            putsFounderName(m)
        when "大島純二"
            putsWittyRemark(m)
        when /\d+年には何店舗.*？$/
            putsNumberOfShops(m, message[1])
        when "0のつく日は"
            putsDonmaruDayPrice(m)
        when /.+丼はおいしい.*？$/
            putsISelf(m)
        when /.*丼丸.*/
        else
            replySomething(m)
        end
    end

    if m.message.include?("丼丸") then
        m.reply "#{m.user.nick}: 呼んだ？"
    end
end

# 税込価格を計算
def 税抜き(税抜価格)
    消費税 = 1.08
    価格 = (税抜価格 * 消費税).round
    # 1の位を 0-4 => 0, 5-9 => 5 にする
    一の位 = 価格 % 10
    価格 -= 一の位 % 5
    return 価格
end
    
#並盛り
def putsRegularSizePrice(m)
    m.reply "並盛りは#{税抜き(500)}円（税込）だどん"
end

#大盛り
def putsLargeSizePrice(m)
    m.reply "ご飯大盛りは#{税抜き(600)}円（税込）だどん"
end

#ネタ大盛り
def putsSushiMaterialLargeSizePrice(m)
    m.reply "ネタ大盛りは#{税抜き(700)}円（税込）だどん"
end

#特盛り
def putsSpecialSizePrice(m)
    m.reply "特盛りは#{税抜き(800)}円（税込）だどん"
end

#競合店
def putsCompetition(m)
    m.reply "丼丸の競合店は丼丸！丼丸に競合店無し！ "
end

#創業者
def putsFounderName(m)
    m.reply "大島純二だどん!"
end

#名言
def putsWittyRemark(m)
    repList = ["人生ing", "人生はツキが３００％", "神様が「もう十分だよ」と言われる時まで、自分らしく生きたい"]
    rand = [*0..repList.length-1].sample
    m.reply "#{repList[rand]}"
end

#店舗数
def putsNumberOfShops(m, str)
    future = str.gsub(/[^0-9]/,"").to_i
    if future == 2014 then
        m.reply "100店舗通過だどん!"
    elsif future == 2015 then
        m.reply "200店舗通過だどん!"
    elsif future < 2007 then
        m.reply "まだ創業してないどん!丼丸は2007年にオープンしたどん!ちなみに笹船は1979年からあるどん!"
    else
        m.reply "#{((future - 2015) * 360.4 + 200).round}店舗だどん!!!"
    end
end

#今日のラッキー丼
def getLuckyDon(m)
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
    end

    imgURL = "http://donmaru.kyu-mu.net/img/don/menu#{rand}.jpg"

    luckeyDon = doc.xpath("//html/body/div/div/h2").text

    if rand == 29 then
        m.reply "#{m.user.nick}にはうんこ丼(うんこ)がおすすめ,#{imgURL}"
    else
        m.reply "#{m.user.nick}の今日のラッキー丼は#{luckeyDon}(#{netaStr}),#{imgURL}"
    end
end

#丼丸プライス
def putsDonmaruDayPrice(m)
    m.reply "500円になるどん!!!"
end

#iSelf
def putsISelf(m)
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

#ランダム
def replySomething(m)
    repList = ["まぬけ", "変態", "バカ", "アホ"]
    rand = [*0..repList.length-1].sample
    m.reply "#{m.user.nick}は#{repList[rand]}だどん"
end

bot.start
