#' @title Get variance components from random effects models
#' @name get_variance
#'
#' @description This function extracts the different variance components of a
#'   mixed model and returns the result as list. Functions like
#'   \code{get_variance_residual(x)} or \code{get_variance_fixed(x)} are shortcuts
#'   for \code{get_variance(x, component = "residual")} etc.
#'
#' @param x A mixed effects model.
#' @param component Character value, indicating the variance component that should
#'   be returned. By default, all variance components are returned. The
#'   distribution-specific (\code{"distribution"}) and residual (\code{"residual"})
#'   variance are the most computational intensive components, and hence may
#'   take a few seconds to calculate.
#' @param verbose Toggle off warnings.
#' @param tolerance Tolerance for singularity check of random effects, to decide
#'   whether to compute random effect variances or not. Indicates up to which
#'   value the convergence result is accepted. The larger tolerance is, the
#'   stricter the test will be. See \code{\link[performance:check_singularity]{check_singularity()}}.
#' @param ... Currently not used.
#'
#' @return A list with following elements:
#'    \itemize{
#'      \item \code{var.fixed}, variance attributable to the fixed effects
#'      \item \code{var.random}, (mean) variance of random effects
#'      \item \code{var.residual}, residual variance (sum of dispersion and distribution)
#'      \item \code{var.distribution}, distribution-specific variance
#'      \item \code{var.dispersion}, variance due to additive dispersion
#'      \item \code{var.intercept}, the random-intercept-variance, or between-subject-variance (\ifelse{html}{\out{&tau;<sub>00</sub>}}{\eqn{\tau_{00}}})
#'      \item \code{var.slope}, the random-slope-variance (\ifelse{html}{\out{&tau;<sub>11</sub>}}{\eqn{\tau_{11}}})
#'      \item \code{cor.slope_intercept}, the random-slope-intercept-correlation (\ifelse{html}{\out{&rho;<sub>01</sub>}}{\eqn{\rho_{01}}})
#'    }
#'
#' @details This function returns different variance components from mixed models,
#'   which are needed, for instance, to calculate r-squared measures or the
#'   intraclass-correlation coefficient (ICC).
#'   \subsection{Fixed effects variance}{
#'    The fixed effects variance, \ifelse{html}{\out{&sigma;<sup>2</sup><sub>f</sub>}}{\eqn{\sigma^2_f}},
#'    is the variance of the matrix-multiplication \ifelse{html}{\out{&beta;&lowast;X}}{\eqn{\beta*X}}
#'    (parameter vector by model matrix).
#'   }
#'   \subsection{Random effects variance}{
#'    The random effect variance, \ifelse{html}{\out{&sigma;<sup>2</sup><sub>i</sub>}}{\eqn{\sigma^2_i}},
#'    represents the \emph{mean} random effect variance of the model. Since
#'    this variance reflect the "average" random effects variance for mixed
#'    models, it is also appropriate for models with more complex random
#'    effects structures, like random slopes or nested random effects.
#'    Details can be found in \cite{Johnson 2014}, in particular equation 10.
#'    For simple random-intercept models, the random effects variance equals
#'    the random-intercept variance.
#'   }
#'   \subsection{Distribution-specific variance}{
#'    The distribution-specific variance,
#'    \ifelse{html}{\out{&sigma;<sup>2</sup><sub>d</sub>}}{\eqn{\sigma^2_d}},
#'    depends on the model family. For Gaussian models, it is
#'    \ifelse{html}{\out{&sigma;<sup>2</sup>}}{\eqn{\sigma^2}} (i.e.
#'    \code{sigma(model)^2}). For models with binary outcome, it is
#'    \eqn{\pi^2 / 3} for logit-link, \code{1} for probit-link, and \eqn{\pi^2 / 6}
#'    for cloglog-links. Models from Gamma-families use \eqn{\mu^2} (as obtained
#'    from \code{family$variance()}). For all other models, the distribution-specific
#'    variance is based on lognormal approximation, \eqn{log(1 + var(x) / \mu^2)}
#'    (see \cite{Nakagawa et al. 2017}). The expected variance of a zero-inflated
#'    model is computed according to \cite{Zuur et al. 2012, p277}.
#'   }
#'   \subsection{Variance for the additive overdispersion term}{
#'    The variance for the additive overdispersion term,
#'    \ifelse{html}{\out{&sigma;<sup>2</sup><sub><em>e</em></sub>}}{\eqn{\sigma^2_e}},
#'    represents \dQuote{the excess variation relative to what is expected
#'    from a certain distribution} (Nakagawa et al. 2017). In (most? many?)
#'    cases, this will be \code{0}.
#'   }
#'   \subsection{Residual variance}{
#'     The residual variance, \ifelse{html}{\out{&sigma;<sup>2</sup><sub>&epsilon;</sub>}}{\eqn{\sigma^2_\epsilon}},
#'     is simply \ifelse{html}{\out{&sigma;<sup>2</sup><sub>d</sub> + &sigma;<sup>2</sup><sub><em>e</em></sub>}}{\eqn{\sigma^2_d + \sigma^2_e}}.
#'   }
#'   \subsection{Random intercept variance}{
#'     The random intercept variance, or \emph{between-subject} variance
#'     (\ifelse{html}{\out{&tau;<sub>00</sub>}}{\eqn{\tau_{00}}}),
#'     is obtained from \code{VarCorr()}. It indicates how much groups
#'     or subjects differ from each other, while the residual variance
#'     \ifelse{html}{\out{&sigma;<sup>2</sup><sub>&epsilon;</sub>}}{\eqn{\sigma^2_\epsilon}}
#'     indicates the \emph{within-subject variance}.
#'   }
#'   \subsection{Random slope variance}{
#'     The random slope variance (\ifelse{html}{\out{&tau;<sub>11</sub>}}{\eqn{\tau_{11}}})
#'     is obtained from \code{VarCorr()}. This measure is only available
#'     for mixed models with random slopes.
#'   }
#'   \subsection{Random slope-intercept correlation}{
#'     The random slope-intercept correlation
#'     (\ifelse{html}{\out{&rho;<sub>01</sub>}}{\eqn{\rho_{01}}})
#'     is obtained from \code{VarCorr()}. This measure is only available
#'     for mixed models with random intercepts and slopes.
#'   }
#'
#' @note This function supports models of class \code{merMod} (including models
#'   from \pkg{blme}), \code{clmm}, \code{cpglmm}, \code{glmmadmb}, \code{glmmTMB},
#'   \code{MixMod}, \code{lme}, \code{mixed}, \code{rlmerMod}, \code{stanreg},
#'   \code{brmsfit} or \code{wbm}. Support for objects of class \code{MixMod}
#'   (\pkg{GLMMadaptiv}), \code{lme} (\pkg{nlme}) or \code{brmsfit} (\pkg{brms})
#'   is experimental and may not work for all models.
#'
#' @references \itemize{
#'  \item Johnson, P. C. D. (2014). Extension of Nakagawa & Schielzeth’s R2 GLMM to random slopes models. Methods in Ecology and Evolution, 5(9), 944–946. \doi{10.1111/2041-210X.12225}
#'  \item Nakagawa, S., Johnson, P. C. D., & Schielzeth, H. (2017). The coefficient of determination R2 and intra-class correlation coefficient from generalized linear mixed-effects models revisited and expanded. Journal of The Royal Society Interface, 14(134), 20170213. \doi{10.1098/rsif.2017.0213}
#'  \item Zuur, A. F., Savel'ev, A. A., & Ieno, E. N. (2012). Zero inflated models and generalized linear mixed models with R. Newburgh, United Kingdom: Highland Statistics.
#'  }
#'
#' @examples
#' \dontrun{
#' library(lme4)
#' data(sleepstudy)
#' m <- lmer(Reaction ~ Days + (1 + Days | Subject), data = sleepstudy)
#'
#' get_variance(m)
#' get_variance_fixed(m)
#' get_variance_residual(m)
#' }
#' @export
get_variance <- function(x, component = c("all", "fixed", "random", "residual", "distribution", "dispersion", "intercept", "slope", "rho01"), verbose = TRUE, ...) {
  UseMethod("get_variance")
}


#' @export
get_variance.default <- function(x, component = c("all", "fixed", "random", "residual", "distribution", "dispersion", "intercept", "slope", "rho01"), verbose = TRUE, ...) {
  if (isTRUE(verbose)) {
    warning(sprintf("Objects of class `%s` are not supported.", class(x)[1]))
  }
  NULL
}


#' @export
get_variance.merMod <- function(x, component = c("all", "fixed", "random", "residual", "distribution", "dispersion", "intercept", "slope", "rho01"), verbose = TRUE, tolerance = 1e-5, ...) {
  component <- match.arg(component)
  tryCatch(
    {
      .compute_variances(x, component = component, name_fun = "get_variance", name_full = "random effect variances", verbose = verbose, tolerance = tolerance)
    },
    error = function(e) {
      NULL
    }
  )
}


#' @export
get_variance.rlmerMod <- get_variance.merMod

#' @export
get_variance.mjoint <- get_variance.merMod

#' @export
get_variance.cpglmm <- get_variance.merMod

#' @export
get_variance.glmmadmb <- get_variance.merMod

#' @export
get_variance.stanreg <- get_variance.merMod

#' @export
get_variance.clmm <- get_variance.merMod

#' @export
get_variance.wbm <- get_variance.merMod

#' @export
get_variance.wblm <- get_variance.merMod

#' @export
get_variance.lme <- get_variance.merMod

#' @export
get_variance.brmsfit <- get_variance.merMod


#' @export
get_variance.glmmTMB <- function(x, component = c("all", "fixed", "random", "residual", "distribution", "dispersion", "intercept", "slope", "rho01"), verbose = TRUE, tolerance = 1e-5, model_component = NULL, ...) {
  component <- match.arg(component)
  tryCatch(
    {
      .compute_variances(x, component = component, name_fun = "get_variance", name_full = "random effect variances", verbose = verbose, tolerance = tolerance, model_component = model_component)
    },
    error = function(e) {
      NULL
    }
  )
}

#' @export
get_variance.MixMod <- get_variance.glmmTMB


#' @export
get_variance.mixed <- function(x, component = c("all", "fixed", "random", "residual", "distribution", "dispersion", "intercept", "slope", "rho01"), verbose = TRUE, tolerance = 1e-5, ...) {
  component <- match.arg(component)
  .compute_variances(x$full_model, component = component, name_fun = "get_variance", name_full = "random effect variances", verbose = verbose, tolerance = tolerance)
}


#' @rdname get_variance
#' @export
get_variance_residual <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "residual", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_variance_fixed <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "fixed", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_variance_random <- function(x, verbose = TRUE, tolerance = 1e-5, ...) {
  unlist(get_variance(x, component = "random", verbose = verbose, tolerance = tolerance, ...))
}

#' @rdname get_variance
#' @export
get_variance_distribution <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "distribution", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_variance_dispersion <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "dispersion", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_variance_intercept <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "intercept", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_variance_slope <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "slope", verbose = verbose, ...))
}

#' @rdname get_variance
#' @export
get_correlation_slope_intercept <- function(x, verbose = TRUE, ...) {
  unlist(get_variance(x, component = "rho01", verbose = verbose, ...))
}
