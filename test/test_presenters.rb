require_relative "test_helper"

require "alki/presenters"

class TestBoardPresenter < Alki::Test
  def setup
    board = {}
    stats = OpenStruct.new(
      averages: {
        "some_list_id" => 20*60*60,
        "another_list_id" => 30*60*60,
        "yet_another_list_id" => 50*60*60},
      wait_times: {
        "1" => {
          "some_list_id" => 1*60*60,
          "another_list_id" => 30*60*60,
          "yet_another_list_id" => 50*60*60},
        "2" => {
          "some_list_id" => 100*60*60},
        "3" => {
          "a_hidden_list" => 10},
        "4" => {
          nil => 0}},
      current_lists: {
        "1" => "yet_another_list_id",
        "2" => "some_list_id",
        "3" => "a_hidden_list",
        "4" => nil}
    )
    lists = [
      {"name" => "Waiting for RPI", "id" => "some_list_id", "hidden" => false},
      {"name" => "Waiting for Interview", "id" => "another_list_id", "hidden" => false},
      {"name" => "A Hidden List", "id" => "a_hidden_list", "hidden" => true},
      {"name" => "Another List", "id" => "yet_another_list_id", "hidden" => false}]
    cards = [
      {"id" => "1", "name" => "card one", "idList" => "foobar"},
      {"id" => "2", "name" => "card two", "idList" => "some_list_id"},
      {"id" => "3"},
      {"id" => "4"}]

    @board_presenter = Presenters::Board.new(board, lists, cards, stats)
  end

  def test_card_durations
    card_durations = nil
    Time.stub :now, Time.parse("2016-01-15T19:20:55.586Z") do
      card_durations = @board_presenter.card_durations
    end

    assert_equal "< 1 day", card_durations["card one"]["some_list_id"]
    assert_equal "1 day", card_durations["card one"]["another_list_id"]
    assert_equal "2 days", card_durations["card one"]["yet_another_list_id"]
    assert_equal "4 days", card_durations["card two"]["some_list_id"]
  end

  def test_lists
    assert_equal(
      %w[ some_list_id another_list_id yet_another_list_id ],
      @board_presenter.visible_lists.map { |list| list["id"] })
  end

  def test_averages
    averages = nil
    Time.stub :now, Time.parse("2016-01-16T19:20:55.586Z") do
      averages = @board_presenter.averages
    end

    assert_equal "< 1 day", averages["some_list_id"]
    assert_equal "1 day", averages["another_list_id"]
    assert_equal "2 days", averages["yet_another_list_id"]
  end

  def test_cards
    assert_equal %w[ 2 1 ], @board_presenter.visible_cards.map { |card| card["id"] }
  end
end
