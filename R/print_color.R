#' @title Coloured console output
#' @name print_color
#'
#' @description Convenient function that allows coloured output in the console.
#'  Mainly implemented to reduce package dependencies.
#'
#' @param text The text to print.
#' @param color,colour Character vector, indicating the colour for printing.
#'   May be one of \code{"red"}, \code{"yellow"}, \code{"green"}, \code{"blue"},
#'   \code{"violet"}, \code{"cyan"} or \code{"grey"}. Formatting is also possible
#'   with \code{"bold"} or \code{"italic"}.
#'
#' @details This function prints \code{text} directly to the console using
#'   \code{cat()}, so no string is returned. \code{color_text()}, however,
#'   returns only the formatted string, without using \code{cat()}.
#'   \code{color_theme()} either returns \code{"dark"} when RStudio is used
#'   with dark color scheme, \code{"light"} when it's used with light theme,
#'   and \code{NULL} if the theme could not be detected.
#'
#' @return Nothing.
#'
#' @examples
#' print_color("I'm blue dabedi dabedei", "blue")
#' @export
print_color <- function(text, color) {
  cat(.colour(colour = color, x = text))
}

#' @rdname print_color
#' @export
print_colour <- function(text, colour) {
  print_color(color = colour, text = text)
}


#' @rdname print_color
#' @export
color_text <- function(text, color) {
  .colour(colour = color, x = text)
}

#' @rdname print_color
#' @export
colour_text <- function(text, colour) {
  .colour(colour = colour, x = text)
}

#' @rdname print_color
#' @export
color_theme <- function() {
  if (requireNamespace("rstudioapi", quietly = TRUE)) {
    if (!rstudioapi::isAvailable()) {
      return(NULL)
    }
    if (!rstudioapi::hasFun("getThemeInfo")) {
      return(NULL)
    }

    theme <- rstudioapi::getThemeInfo()
    if (isTRUE(theme$dark)) {
      return("dark")
    } else {
      return("light")
    }
  }
  return(NULL)
}
