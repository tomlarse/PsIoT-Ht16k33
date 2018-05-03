[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSProvideCommentHelp", "", Justification="Just a library")]
# For each row, the bits for LED column n are 07654321 (n+1 mod 8)
$Sprites = @{
    Pslogo = @( "00100000",
                "00100000",
                "00100100",
                "00001110",
                "00011111",
                "10111011",
                "10110001",
                "10100000"
    )
    Smiley = @( "00011110",
                "00100001",
                "11010010",
                "11000000",
                "11010010",
                "11001100",
                "00100001",
                "00011110"
    )
    SadJoey = @( "00011110",
                 "00100001",
                 "11010010",
                 "11000000",
                 "11000000",
                 "11011100",
                 "00100001",
                 "00011110"
    )
}
