require_relative "card.rb"
require_relative "deck.rb"
require_relative "player.rb"
require "byebug"

class War

    def initialize(num_players)
        @deck = Deck.new
        @players = []
        (1..num_players).each do |id|
            @players << Player.new(id.to_s)
        end
        deal
    end

    def deal
        @deck.shuffle
        until @deck.empty?
            @players.each do |player|
                player.down_cards << @deck.draw_card if !@deck.empty?
            end
        end
    end

    def remove_player(id)
        @players.keep_if { |player| player.id != id }
    end

    def play
        while true
            @players.each do |player|
                self.remove_player(player.id) if player.lost?
                player.reset_down_cards if player.down_cards.empty?
                player.play_card
            end
            break if @players.length < 2

            max = @players.max_by { |player| player.up_card.point_value }
            winners = @players.select { |player| player.up_card.point_value == max.up_card.point_value }
            if winners.length == 1
                won_cards = []
                @players.each do |player|
                    if !winners.include?(player)
                        player.give_up_cards.each do |card|
                            won_cards << card
                        end
                    end
                end
                winners[0].win_battle(won_cards)
            else
                while winners.length > 1
                    losers = []
                    winners.each do |player|
                        if !player.can_battle?
                            losers << player
                        else
                            player.battle_cards
                        end
                    end
                    winners.keep_if { |winner| !losers.include?(winner) }
                    max = winners.max_by { |player| player.up_card.point_value }
                    winners = winners.select { |player| player.up_card.point_value == max.up_card.point_value }
                    p winners.length
                end
                won_cards = []
                @players.each do |player|
                    if !winners.include?(player)
                        player.give_up_cards.each do |card|
                            won_cards << card
                        end
                    end
                end
                winners[0].win_battle(won_cards)
            end

        end
        puts "Player #{@players[0].id} wins!"
    end

end

war = War.new(2)
war.play