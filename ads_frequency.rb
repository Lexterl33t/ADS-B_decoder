=begin
    ADS-B diffusion Frequence: 1090MHz

    [[ ADS Matériel ]]:
        1 - Dongle (R820T2)
        2 - Antenne à polarisation vertical (F: 1090MHz) (longueur d'onde : 27.5 cm)
        3 - Logiciel d'écoute et de decodage ADS-B
        4 - Logiciel pour afficher graphiquement les données de localisation de l'avion reçu
        5 - LNA (eviter les figures de bruit)

    [[ Radare secondaire ]]
        [ Modes de communications ]
            Mode A:
                 8 micros secondes
                ----------------------
                __**__--____**_______
            Légende:
                ** => P1 & P3
                -- => P2
            Description:
                P1 & P2 sont les deux impulsions principales, et sont envoyé à une intervale
                de 8 micro seconde. Juste après l'impulsion P1, il survient l'impulsion P2
                Si l'impulsion P2 est superieur à P1 cela veut dire que l'avion est proche du
                radar

            Mode C:
                  21 micros secondes
                ----------------------
                __**__--____**_______
            Légende:
                ** => P1 & P3
                -- => P2
            Description:
                P1 & P2 sont les deux impulsions principales, et sont envoyé à une intervale
                de 21 micro seconde. Juste après l'impulsion P1, il survient l'impulsion P2
                Si l'impulsion P2 est superieur à P1 cela veut dire que l'avion est proche du
                radar

        [ Mode de réponse A/C ]
            Mode A/C
                __**_-_-_-_-_-_-_x_-_-_-_-_-_-_**_x_x_**__

            Légende:
                ** => F1 && F2 && SPI
                - => 1 impulsion
                
            Description:
                En effet chaque réponse est constitué de deux impulsions persistentes appelé F1 & F2 ayant un interval de 20.3micro sec
                Durant cette periode soit l'altitude, soit l'identité est codé en 13 impulsion. Chaque impulsion est 1 bit, si l'impulsion est absente
                le bit sera à 0 si au contraire il est présent il aura le bit à 1 en réalité cela marche pour 12 impulsions car l'impulsion appelé
                impulsion centrale est la vérification. A des fins de vérification requis par le controleur aérien, il peut y avoir une impulsion appelé
                SPI juste après deux impulsion à bit 0 qui précède l'impulsion F2.

    [[ Mode S ]]
        [ Interrogation mode S ]
            Mode S (Short && long):
                __**_**_*********_____________

            Légende:
                ** => P1 && P2
                ********* => P5 (data block)

            Description:
                Il existe deux type d'interrogation dans le mode S short et long la différence est plutot simple dans le short on peut stocker 56 bits de data
                et dans le mode S long on peut stocker 112 bits de data. Comme le mode A/C il y a l'impulsion P1 & P2, P2 est fait pour supprimer les lobe. P1
                est la première impulsion. P5 correspond au block de données. Les données contenu dans le block de données utilisent la modulation
                par décalage de phase differentiel (DPSK)

        [ Réponse mode S ]
            .....

    [[ ADB-S ]]
        L'ADB-S est un système de surveillance par satellite. Des paramètres tels que la position, la vitesse et l'identification sont transmis via
        le squitter etendu Mode S.
        
        [ Trame ADB-S ]
            Trame:
                +----------+----------+-------------+------------------------+-----------+
                DF (5)  |  CA (3)  |  ICAO (24)  |         ME (56)        |  PI (24)  |
                +----------+----------+-------------+------------------------+-----------+
                
            Description:
                Une trame ADB-S a une longueur de 112 bits il se compose de 5 parties principales.
                Les 5 premiers bits correspondent au type d'avions par exemple les avions civils sont identifié
                par Downlink 17 cela donne en binaire: 10001, les 3 prochains bits (6..8) correspondent à la capacité du transpondeur.
                Les 24 prochains bits (9..32) c'est le code du transpondeur(adresse de l'aeronef). Les 56 prochains bits (33..88) cela correspond
                au message, squitter etendu. 
                Les 24 derniers bits (89..112) c'est l'id de l'interrogateur.

                Remarque: les les 4 premiers bits du MOI c'est le type code (squitter etendu)

                Si la valeur du DF est égal à 17 cela veut dire que c'est un signal ADS-B, si la valeur du DF est égal à 18 cela veut dire
                que c'est un signal TIS-B dans les deux cas ce sont des signal n'ayant aucunement besoin d'une interrogation.
                
        [ Aptitude ]
            Le CA definit le niveau du transpondeur (avion). Celui ci à un range maximum de 0 à 7.
            Voici le tableau des définitions:

            0 => transpodeur de niveau 1
            1..3 => Réservé
            4 => Transpondeur niveau 2+, avec la possibilité de changer CA à 7, sur le sol
            5 => Transpondeur niveau 2+, avec la possibilité de changer CA à 7, aéroporté
            6 => Transpondeur niveau 2+, avec la possibilité de changer CA à 7, au sol ou en vol
            7 => Signifie que la valeur de la demande de liaison descendante est 0,ou le statut du vol est 2, 3, 4 ou 5,soit en vol soit au sol

        [ Adresse OACI ]
            IACO c'est sur 24 bits et cela contient l'adresse (l'identifiant unique) de l'aronef.

        [ Type de message ]
            Le code du message est contenu dans les 4 ou 5 premiers bits du ME segment.
            Voici le tableau d'identification.

            1..4 => Identification de l'avion
            5..8 => Position de surface
            9..18 => Position aeroporté (baro altitude)
            19 => Vitesse aeroporté
            20..22 => Position aeroporté avec hauteur GNSS
            23..27 => Réservé
            28 => Status de l'avion
            29 => etat de la cible et information de l'état
            31 => etat d'exploitation de l'aeronef

        [ Decoding message ]

            Message brut: 8D4840D6202CC371C32CE0576098

            +-----+------------+--------------+----------------------+--------------+
            | HEX | 8D         | 4840D6       | 202CC371C32CE0       | 576098       |
            +-----+------------+--------------+----------------------+--------------+
            | BIN | 10001  101 | 010010000100 | [00100]0000010110011 | 010101110110 |
            |     |            | 000011010110 | 00001101110001110000 | 000010011000 |
            |     |            |              | 110010110011100000   |              |
            +-----+------------+--------------+----------------------+--------------+
            | DEC |  17    5   |              | [4] ...............  |              |
            +-----+------------+--------------+----------------------+--------------+
            |     |  DF    CA  |   ICAO       |          ME          | PI           |
            |     |            |              | [TC] ..............  |              |
            +-----+------------+--------------+----------------------+--------------+


            à Présent je comprend rapidement comment décoder.

        [ Identification de l'avion ]




=end

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
error, tc, ca, name = dec.decode(0x8D4840D6202CC371C32CE0576098)

puts "Infos ADS-B -> 0x8D4840D6202CC371C32CE0576098"
puts "Nom appareil => #{name}"
puts "Type de code => #{tc}"
puts "Catégorie => #{ca}"

