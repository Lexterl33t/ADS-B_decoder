

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
error, tc, ca, name = dec.decode(0x8D4840D6202CC371C32CE0576098)

puts "Infos ADS-B -> 0x8D4840D6202CC371C32CE0576098"
puts "Nom appareil => #{name}"
puts "Type de code => #{tc}"
puts "Catégorie => #{ca}"

