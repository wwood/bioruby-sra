require 'helper'
require 'pp'
require 'bio-commandeer'
require 'tmpdir'
require 'tempfile'

class TestSRADownload < Test::Unit::TestCase
  include Bio::SRA::Tables

  path_to_script = File.join(File.dirname(__FILE__),'..','bin','sra_download')

  should "(really) download a single run file" do
    expected_md5sum = '52b04843abcddb4ad4fa124c471c23ce  -'+"\n"

    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        Bio::Commandeer.run "#{path_to_script} ERR229501"
        assert_equal expected_md5sum,
          Bio::Commandeer.run("cat ERR229501.sra |md5sum")
      end
    end
  end

  should 'download all files from a study' do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        expected = [
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033547/SRR033547.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033549/SRR033549.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033548/SRR033548.sra',
          ].join("\n")+"\n"

        assert_equal expected, Bio::Commandeer.run("#{path_to_script} --dry-run SRP001692 -q")
      end
    end
  end

  should 'download all files from an experiment' do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        expected = [
          #'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033547/SRR033547.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033549/SRR033549.sra',
          #'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033548/SRR033548.sra',
          ].join("\n")+"\n"

        assert_equal expected, Bio::Commandeer.run("#{path_to_script} --dry-run SRX015618 -q")
      end
    end
  end

  should 'download all files from a sample' do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        expected = [
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033547/SRR033547.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033549/SRR033549.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033548/SRR033548.sra',
          ].join("\n")+"\n"

        assert_equal expected, Bio::Commandeer.run("#{path_to_script} --dry-run SRS009755 -q")
      end
    end
  end


  should 'handle mixed run and experiment input in a file input' do
    Dir.mktmpdir do |tmp|
      Dir.chdir(tmp) do
        expected = [
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033547/SRR033547.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033549/SRR033549.sra',
          'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR033/SRR033548/SRR033548.sra',
          ].join("\n")+"\n"

        Tempfile.open("t") do |infile|
          infile.puts 'SRS009755'
          infile.puts 'SRR033548'
          infile.close

          assert_equal expected, Bio::Commandeer.run("#{path_to_script} --dry-run -f #{infile.path} -q")
        end
      end
    end
  end
end
