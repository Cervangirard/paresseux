#' AppLaunch
#'
#' A tools to launch app
#'
#' @return methods to manipulate your app
#'
#' @section Methods:
#' \describe{
#'   \item{\code{show_terminal}}{Display the terminal where your application is launched}
#'   \item{\code{stop}}{Stop your app}
#'   \item{\code{get_buffer}}{Get what you have in your terminal}
#'   \item{\code{get_url}}{Get the url of your application}
#'   \item{\code{open_app}}{Open the url of your application}
#'   \item{\code{restart}}{Restart your application}
#'   \item{\code{is_running}}{Test your terminal is still running}
#'   \item{\code{auto_restart}}{Monitors your directory and restarts your application if there is a change}
#'  }
#'
#' @importFrom R6 R6Class
#' @importFrom rlang is_empty
#' @importFrom golem set_golem_wd document_and_reload
#' @importFrom servr httw daemon_stop
#' @importFrom withr with_dir
#' @export

AppLaunch <- R6Class(
  "AppLaunch",
  public = list(
    process = character(0),
    dir_of_app = character(0),
    path_to_run_dev = character(0),
    url = character(0),
    initialize = function(is_golem = TRUE,
                              app_dir = ".") {
      if (is_golem) {
        path <- set_golem_wd(app_dir, talkative = FALSE)
        self$dir_of_app <- path
        dev <- file.path(path, "dev")
        list_run_dev <- list.files(dev, pattern = "run_dev")
        if (is_empty(self$path_to_run_dev)) {
          choice <- menu(list_run_dev, title = "Choose you run_dev:")
          self$path_to_run_dev <- file.path(dev, list_run_dev[choice])
        }
        if (file.exists(self$path_to_run_dev)) {

          with_dir(self$dir_of_app, {
            command <- paste0("Rscript '", self$path_to_run_dev, "'")
            self$process <- rstudioapi::terminalExecute(
              command,
              show = FALSE
            )
          })
        } else {
          stop("We don't find this run_dev")
        }
      } else {
        message("
                It'better is you use golem package for your app")
        self$dir_of_app <- app_dir
        command <- paste0("shiny::shinyAppDir(\"", app_dir, "\")")
        self$process <- rstudioapi::terminalExecute(
          command,
          show = FALSE
        )
      }

      message("
              Waiting to launch the app")
      Sys.sleep(4)

      self$url <- self$get_url()
    },
    show_terminal = function() {
      rstudioapi::terminalActivate(
        self$process
      )
    },
    stop = function() {
      rstudioapi::terminalKill(
        self$process
      )
    },
    get_buffer = function() {
      rstudioapi::terminalBuffer(
        self$process
      )
    },
    get_url = function() {
      get_address <- self$get_buffer()
      url <- get_address[grep("Listening", get_address)]
      url <- gsub(pattern = "Listening on ", replacement = "", x = url)
      url
    },
    open_app = function() {
      browseURL(self$url)
    },
    restart = function() {
      self$stop()
      self$initialize()
      self$open_app()
    },
    is_running = function() {
      rstudioapi::terminalBusy(
        self$process
      )
    },
    auto_restart = function() {
      private$server_restart <- httw(
        dir = self$dir_of_app,
        watch = self$dir_of_app,
        handler = function(...) {
          self$restart()
        }
      )
    },
    stop_restart = function() {
      self$stop()
      private$server_restart$stop_server()
      daemon_stop()
    }
  ),
  private = list(
    server_restart = list(),
    first = TRUE
  )
)
