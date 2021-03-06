#' @title Checks if a model is a generalized additive model
#' @name is_gam_model
#'
#' @description Small helper that checks if a model is a generalized additive
#' model.
#'
#' @param x A model object.
#'
#' @return A logical, \code{TRUE} if \code{x} is a generalized additive model
#' \emph{and} has smooth-terms
#'
#' @note This function only returns \code{TRUE} when the model inherits from a
#' typical GAM model class \emph{and} when smooth terms are present in the model
#' formula. If model has no smooth terms or is not from a typical gam class,
#' \code{FALSE} is returned.
#'
#' @examples
#' if (require("mgcv")) {
#'   data(iris)
#'   model1 <- lm(Petal.Length ~ Petal.Width + Sepal.Length, data = iris)
#'   model2 <- gam(Petal.Length ~ Petal.Width + s(Sepal.Length), data = iris)
#'   is_gam_model(model1)
#'   is_gam_model(model2)
#' }
#' @export
is_gam_model <- function(x) {
  !is.null(find_smooth(x, flatten = TRUE)) && inherits(.get_class_list(x), .get_gam_classes())
}
