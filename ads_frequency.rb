

module ADS_B
    class Decoder
        def parse_segment_msg(msg)
            return msg.to_s(2)[0..4], 
                   msg.to_s(2)[5..7], 
                   msg.to_s(2)[8..31], 
                   msg.to_s(2)[32..87], 
                   msg.to_s(2)[88..111]
        end

=begin
        ///////////////////////////////
        //// Identification trame ////
        ////////////////////////////
=end
        def parse_me_trame_identification_aircraft(me)
            return me[0..4], me[5..7], 
                    [me[8..13], me[14..19], 
                    me[20..25], me[26..31], 
                    me[32..37], me[38..43], 
                    me[44..49], me[50..55]] 
        end

        def is_identification_tc(me)
            return true if me[0..4].to_i(2) <= 4 && me[0..4].to_i(2) >= 1
        end

        def decode_icao_value(identification_trame_me)
            tc, ca, c = parse_me_trame_identification_aircraft(identification_trame_me)
            if(is_identification_tc(identification_trame_me))
                c.map.with_index do |char, i|
                    if(char.to_i(2) >= 1 && char.to_i(2) <= 26)
                        c[i] = ((char.to_i(2)-1 & 31) + 65).chr
                    else
                        c[i] = (char.to_i(2) != 32 ? char.to_i(2).chr : "_")
                    end
                end
                return true, tc.to_i(2), ca.to_i(2), c.join
            else
                return "NOT_VALID_IDENTIFICATION_AIRCRAFT_ME", nil, nil, nil
            end
        end
=begin
        ///////////////////////////////////
        //// End Identification trame ////
        /////////////////////////////////
=end 


=begin
        ///////////////////////////////
        ////   Position trame    ////
        ////////////////////////////
=end

        def parse_position_me_trame(me_trame)
            return me_trame[0..4],me_trame[5..6], 
                   me_trame[7], me_trame[8..19], 
                   me_trame[20], me_trame[21],
                   me_trame[22..38], me_trame[39..55]
        end

        def mod(x, y)
            return x-y*((x/y).floor)
        end

        def global_unambiguous_position(me1, me2)
            tc1, ss1, saf1, alt1, t1, f1, lat_pcr1, long_pcr1 = self.parse_position_me_trame(me1)
            tc2, ss2, saf2, alt2, t2, f2, lat_pcr2, long_pcr2 = self.parse_position_me_trame(me2)
            #calculate hint of lat
            j = (59*lat_pcr1.to_i(2)/2**17-60*lat_pcr2.to_i(2)/2**17+1/2).floor
            #decode lat even
            lat_even = 360/4*15*(mod(j, 60)+lat_pcr1.to_i(2))
            puts lat_even
        end

        def decode_position(trame_even, trame_odd)
            df_even, ca_even, icao_even, me_even, pi_even = self.parse_segment_msg(trame_even)
            df_odd, ca_odd, icao_odd, me_odd, pi_odd = self.parse_segment_msg(trame_odd)

            global_unambiguous_position(me_even, me_odd)
        end



=begin
        ///////////////////////////////
        ////  End Position trame  ////
        ////////////////////////////
=end

        def decode(msg)
            if(msg.to_s(2).length == 112)
                df, ca, icao, me, pi = self.parse_segment_msg(msg)
                if(self.is_identification_tc(me))
                    return (error, tc, ca, name = self.decode_icao_value(me))
                end
            else
                return "NOT_VALID_LENGTH_TRAME", nil
            end
        end
    end
end


dec = ADS_B::Decoder.new
dec.decode_position(0x8D40621D58C382D690C8AC2863A7, 0x8D40621D58C386435CC412692AD6)