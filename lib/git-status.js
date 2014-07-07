var Repo = require('git').Repo;

module.exports = function() {

  new Repo("./", function(err, repo) {
    repo.status(function(err, status) {
      var filenames = Object.keys(status.files)
      var modified = filenames.filter(function(filename) {
        return status.index(filename).type == 'M'
      })
      return modified;
    })
  });

}
