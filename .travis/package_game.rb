require 'pathname'

print <<SNIP
(function () {
    var canvas = document.getElementById('canvas');
    var Module = {
        arguments: ['./'],
        printErr: console.error.bind(console),
        setStatus: function (e) {
            if (!e && Module.didSyncFS && Module.remainingDependencies === 0)
                Module.callMain(Module.arguments);
        },
        canvas: (function() {
          return canvas;
        })(),
        didSyncFS: false,
        totalDependencies: 0,
        remainingDependencies: 0,
        expectedDataFileDownloads: 1,
        finishedDataFileDownloads: 0,
        monitorRunDependencies: function(left) {
          this.remainingDependencies = left;
          this.totalDependencies = Math.max(this.totalDependencies, left);
        }
    };
    canvas.module = Module;

    function runWithFS () {
SNIP

count = 0
dir = Pathname.new ARGV.shift
ARGV.each do |name|
  file = Pathname.new name
  if file.directory?
    Pathname.glob File.join(file, "**", "*") do |file|
      next if file.directory?
      puts "var fileData#{count+=1} = [];"
      file.binread.unpack('C*').each_slice 10240 do |bytes|
        puts "fileData#{count}.push.apply(fileData#{count}, #{bytes});" #[#{str.bytes.join ","}]);"
      end
      puts "Module['FS_createDataFile']('#{file.dirname.relative_path_from dir}', '#{file.basename}', fileData#{count}, true, true);"
    end
  else
    puts "var fileData#{count+=1} = [];"
    file.binread.unpack('C*').each_slice 10240 do |bytes|
      puts "fileData#{count}.push.apply(fileData#{count}, #{bytes});" #[#{str.bytes.join ","}]);"
    end
    puts "Module['FS_createDataFile']('#{file.dirname.relative_path_from dir}', '#{file.basename}', fileData#{count}, true, true);"
  end
end

print <<SNIP
    }

    if (Module['calledRun']) {
      runWithFS();
    } else {
      if (!Module['preRun']) Module['preRun'] = [];
      Module["preRun"].push(runWithFS); // FS is not initialized yet, wait for it
    }

    window.mod = Module;
})();
SNIP
