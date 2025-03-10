defmodule OpenskillTest do
  use ExUnit.Case
  @epsilon 0.001

  describe "#rating" do
    test "returns a default rating" do
      {mu, sigma} = Openskill.rating()
      assert mu == 25.0
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns a rating with just mu initialized" do
      {mu, sigma} = Openskill.rating(100)
      assert mu == 100
      assert_in_delta sigma, 8.333, @epsilon
    end

    test "returns an initialized rating" do
      {mu, sigma} = Openskill.rating(1500, 32)
      assert mu == 1500
      assert sigma == 32
    end
  end

  describe "#ordinal" do
    test "accepts a gaussian, returns an ordinal" do
      assert 15 == Openskill.ordinal({30, 5})
    end

    test "default ordinal is 0" do
      assert 0 == Openskill.ordinal(Openskill.rating())
    end
  end

  describe "#rate" do
    test "rate accepts and runs a placket-luce model by default" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] = Openskill.rate([[a1], [b1], [c1], [d1]], tau: 0)

      assert [
               [{30.209971908310553, 4.764898977359521}],
               [{27.64460833689499, 4.882789305097372}],
               [{17.403586731283518, 6.100723440599442}],
               [{19.214790707434826, 7.8542613981643985}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "rate accepts and runs a placket-luce model with tau" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] = Openskill.rate([[a1], [b1], [c1], [d1]], tau: 0.01)

      assert [
               [{30.20997558824299, 4.764909330988368}],
               [{27.64461002009721, 4.882799245921361}],
               [{17.403587237635527, 6.100731158882956}],
               [{19.21478808745494, 7.854267281042293}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "rate accepts and runs a placket-luce model with tau and prevent_sigma_increase" do
      a1 = Openskill.rating(6.672, 0.0001)
      b1 = Openskill.rating(29.182, 4.782)

      [[a2], [b2]] = Openskill.rate([[a1], [b1]], tau: 0.01, prevent_sigma_increase: true)

      {_a1_mu, a1_sigma} = a1
      {_a2_mu, a2_sigma} = a2

      assert a2_sigma <= a1_sigma

      assert [[{6.672012533190158, 0.0001}], [{26.316243774876106, 4.7540633621019}]] == [
               [a2],
               [b2]
             ]
    end

    test "rate accepts and runs a placket-luce model by default for teams" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2, b2], [c2, d2]] = Openskill.rate([[a1, b1], [c1, d1]], tau: 0)

      assert [
               [{29.607218266047376, 4.754597315295896}],
               [{27.624480490655575, 4.89211428863373}],
               [{15.953288649990139, 6.125357588584119}],
               [{23.708690706816785, 8.111298027437888}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "rate accepts and runs a placket-luce model by default for teams with tau" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2, b2], [c2, d2]] = Openskill.rate([[a1, b1], [c1, d1]], tau: 0.01)

      assert [
               [{29.60722003260825, 4.754607604502581}],
               [{27.624482251695827, 4.892124276331747}],
               [{15.953286947567106, 6.1253654293947335}],
               [{23.708689129525133, 8.111303923213725}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "rate accepts and runs a placket-luce model by default for teams with tau and prevent_sigma_increase" do
      a1 = Openskill.rating(9.182, 0.0001)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2, b2], [c2, d2]] =
        Openskill.rate([[a1, b1], [c1, d1]], tau: 0.01, prevent_sigma_increase: true)

      {_a1_mu, a1_sigma} = a1
      {_a2_mu, a2_sigma} = a2

      assert a2_sigma <= a1_sigma

      assert [
               [{9.182004653636957, 0.0001}],
               [{28.301285923165363, 4.889318394468611}],
               [{14.87349383521136, 6.076727029758966}],
               [{21.768626152890867, 7.992333183226455}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "accepts bradley-terry with full pairings" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] =
        Openskill.rate(
          [[a1], [b1], [c1], [d1]],
          model: Openskill.BradleyTerryFull,
          tau: 0
        )

      assert [
               [{31.643721109067318, 4.5999011726035866}],
               [{27.579203181313282, 4.711537319421646}],
               [{16.96606210683349, 5.824625458553909}],
               [{15.834345097607386, 7.1129977453618745}]
             ] == [[a2], [b2], [c2], [d2]]
    end

    test "accepts thurstone mosteller with part pairings" do
      a1 = Openskill.rating(29.182, 4.782)
      b1 = Openskill.rating(27.174, 4.922)
      c1 = Openskill.rating(16.672, 6.217)
      d1 = Openskill.rating()

      [[a2], [b2], [c2], [d2]] =
        Openskill.rate(
          [[a1], [b1], [c1], [d1]],
          model: Openskill.ThurstoneMostellerPart,
          tau: 0
        )

      assert [
               [{30.872374450270552, 4.56949895985143}],
               [{26.041422654098124, 4.568136168196902}],
               [{19.808527703340072, 5.575297670506283}],
               [{17.47779366561652, 7.175216992011798}]
             ] == [[a2], [b2], [c2], [d2]]
    end
  end

  describe "#rate_with_ids" do
    test "rate_with_ids accepts returns ids next to values" do
      # The algorithm is already tested, we are instead testing the formatting
      # of this wrapper function
      a1 = {"a1", Openskill.rating(29.182, 4.782)}
      b1 = {"b1", Openskill.rating(27.174, 4.922)}
      c1 = {"c1", Openskill.rating(16.672, 6.217)}
      d1 = {"d1", Openskill.rating()}

      result = Openskill.rate_with_ids([[a1], [b1], [c1], [d1]])

      assert match?(
               [
                 [{"a1", {_, _}}],
                 [{"b1", {_, _}}],
                 [{"c1", {_, _}}],
                 [{"d1", {_, _}}]
               ],
               result
             )

      # Ensure the format of the result is correct in a 2v2 situation too
      result = Openskill.rate_with_ids([[a1, b1], [c1, d1]])

      assert match?(
               [
                 [{"a1", {_, _}}, {"b1", {_, _}}],
                 [{"c1", {_, _}}, {"d1", {_, _}}]
               ],
               result
             )

      # Now ensure it adheres to the :as_map option
      result = Openskill.rate_with_ids([[a1, b1], [c1, d1]], as_map: true)

      assert match?(
               %{
                 "a1" => {_, _},
                 "b1" => {_, _},
                 "c1" => {_, _},
                 "d1" => {_, _}
               },
               result
             )
    end
  end

  describe "predictwin" do
    test "predictwin works" do
      teams = [
        [{25, 8.333}, {30, 6.666}],
        [{27, 7.0}, {28, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5000000005, 0.5000000005]

      teams = [
        [{25, 1}, {30, 6.666}],
        [{27, 7.0}, {28, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5000000005, 0.5000000005]

      teams = [
        [{25, 8.333}, {30, 6.666}],
        [{27, 1}, {28, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5000000005, 0.5000000005]
    end

    test "predictwin works compared with python" do
      teams = [
        [{25, 25 / 3}],
        [{33.564, 1.123}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.202122560771339, 0.797877439228661]
      # These results match python docs:
      # https://github.com/vivekjoshy/openskill.py/blob/main/docs/source/manual.rst#predicting-winners
    end

    test "same team mu means equal chance of winning" do
      # It doesn't matter the standard deviation of teams so long as team mu is equal
      teams = [
        [{50, 1}, {0, 6.666}],
        [{25, 1}, {25, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5000000005, 0.5000000005]

      # Increasing the mu of one player should increase their odds of winning
      # Let's increase the skill of the second player on first team
      teams = [
        [{50, 1}, {1, 6.666}],
        [{25, 1}, {25, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5377401553734663, 0.4622598446265337]

      # Increasing uncertainty of either team will move the result closer to 50%
      # Let's increase uncertainty of first player in first team
      teams = [
        [{50, 8}, {1, 6.666}],
        [{25, 1}, {25, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5301795848706835, 0.4698204151293165]

      # Increasing uncertainty of either team will move the result closer to 50%
      # Let's increase uncertainty of first player in second team and reverting the previous uncertainty change
      teams = [
        [{50, 1}, {1, 6.666}],
        [{25, 8}, {25, 5.5}]
      ]

      result = Openskill.predict_win(teams)
      assert result == [0.5301795848706835, 0.4698204151293165]
    end
  end
end
