import QtQuick

QtObject {
    // Roboto Flex is customized to feel geometric, unserious yet not overly kiddy
    property var main: ({
            // Uppercase height (Raised from 712 to be more distinguishable from lowercase)
            "YTUC": 716,
            // Figure (numbers) height (Lowered from 738 to match uppercase)
            "YTFI": 716,
            // Ascender height (Lowered from 750 to match uppercase)
            "YTAS": 716,
            // Lowercase height (Lowered from 514 to be more distinguishable from uppercase)
            "YTLC": 490,
            // Counter width (Raised from 468 to be less condensed, less serious)
            "XTRA": 488,
            // Width (Space out a tiny bit for readability)
            "wdth": 105,
            // Grade (Increased so the 6 and 9 don't look weak)
            "GRAD": 175,
            // Weight (Lowered to compensate for increased grade)
            "wght": 300
        })
    // Rubik simply needs regular weight to override that of the main font where necessary
    property var numbers: ({
            "wght": 400
        })
    // Slightly bold weight for title
    property var title: ({
            // "YTUC": 716, // Uppercase height (Raised from 712 to be more distinguishable from lowercase)
            // "YTFI": 716, // Figure (numbers) height (Lowered from 738 to match uppercase)
            // "YTAS": 716, // Ascender height (Lowered from 750 to match uppercase)
            // "YTLC": 490, // Lowercase height (Lowered from 514 to be more distinguishable from uppercase)
            // "XTRA": 490, // Counter width (Raised from 468 to be less condensed, less serious)
            // "wdth": 110, // Width (Space out a tiny bit for readability)
            // "GRAD": 150, // Grade (Increased so the 6 and 9 don't look weak)
            "wght": 900 // Weight (Lowered to compensate for increased grade)
        })
}
