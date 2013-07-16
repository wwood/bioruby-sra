module Bio
  module SRA
    SUBMISSION = 'submission'
    STUDY = 'study'
    SAMPLE = 'sample'
    EXPERIMENT = 'experiment'
    RUN = 'run'

    class Accession
      @@log = Bio::Log::LoggerPlus['bio-sra']

      # valid_in_type <- c(SRA = "submission", ERA = "submission",
      # DRA = "submission", SRP = "study", ERP = "study", DRP = "study",
      # SRS = "sample", ERS = "sample", DRS = "sample", SRX = "experiment",
      # ERX = "experiment", DRX = "experiment", SRR = "run",
      # ERR = "run", DRR = "run")
      ACCESSION_TO_TYPE = {
        'SRA' => Bio::SRA::SUBMISSION,
        'ERA' => Bio::SRA::SUBMISSION,
        'DRA' => Bio::SRA::SUBMISSION,
        'SRP' => Bio::SRA::STUDY,
        'ERP' => Bio::SRA::STUDY,
        'DRP' => Bio::SRA::STUDY,
        'SRS' => Bio::SRA::SAMPLE,
        'ERS' => Bio::SRA::SAMPLE,
        'DRS' => Bio::SRA::SAMPLE,
        'SRX' => Bio::SRA::EXPERIMENT,
        'ERX' => Bio::SRA::EXPERIMENT,
        'DRX' => Bio::SRA::EXPERIMENT,
        'SRR' => Bio::SRA::RUN,
        'ERR' => Bio::SRA::RUN,
        'DRR' => Bio::SRA::RUN,
      }

      TYPE_TO_COLUMN = {
        Bio::SRA::SUBMISSION => :submission_accession,
        Bio::SRA::STUDY => :study_accession,
        Bio::SRA::SAMPLE => :sample_accession,
        Bio::SRA::EXPERIMENT => :experiment_accession,
        Bio::SRA::RUN => :run_accession,
      }

      def self.classify_accession_type(accession)
        type = ACCESSION_TO_TYPE[accession[0..2]]
        if type.nil?
          raise "Unrecognised accession string '#{accession}'"
        end
        @@log.debug "Classified #{accession} as SRA type '#{type}'" if @@log.debug?
        return type
      end

      # Given an accession, return the column name it in the SRA table that contains it as a symbol.
      # e.g. accession_to_column_name('SRR617581') => :run_accession
      def self.accession_to_column_name(accession)
        TYPE_TO_COLUMN[classify_accession_type(accession)]
      end

      def self.format_symbol_to_extension(format_symbol)
        non_standard_extensions = {
          :sralite => '.lite.sra',
          :fastq_gz => '.fastq.gz',
        }
        style = format_symbol_to_standard_text format_symbol

        # Default extension is the same as the format
        style_extension = non_standard_extensions[format_symbol]
        style_extension ||= ".#{style}"

        return style_extension
      end

      def self.format_symbol_to_standard_text(format_symbol)
        formats = {
          :sralite => 'litesra',
          :sra => 'sra',
          :fastq_gz => 'fastq',
          :sff => 'sff'
        }
        style = formats[format_symbol]
        if style.nil?
          raise "Unexpected download format detected #{options[:format]}, I need one of '#{formats.keys.join(', ')}'"
        end
        return style
      end

      # Return the URL where a run can be downloaded. Only works if the accession is a run accession e.g. SRR000002 or DRR000002. To get run accessions from other accession type e.g. SRP000002, try Bio::SRA::Sra
      #
      # Options:
      # :source: either :ncbi (default), or :ebi
      # :format: either :sralite (default if :source if :ncbi), :fastq_gz (default if :source is :ebi), :sra
      # :layout: either :single (default), :paired1, or :paired2. :paired1 for the first half, :paired2 for the second half. Only required when :source => :ebi, otherwise not used
      def self.run_download_url(run_accession, options={})
        options ||= {}
        options[:source] ||= :ncbi
        if options[:source] == :ebi
          options[:format] ||= :fastq
          options[:layout] ||= :single
        else
          options[:format] ||= :sralite #default to sralite
        end


        type = classify_accession_type(run_accession)
        unless type == Bio::SRA::RUN
          raise "Unexpected type of accession for '#{run_accession}': Expected #{Bio::SRA::RUN} but was #{type}"
        end

        style = format_symbol_to_standard_text options[:format]
        style_extension = format_symbol_to_extension options[:format]

        if options[:source] == :ncbi
          # e.g.
          # ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/litesra/DRR/DRR000/DRR000002/DRR000002/DRR000002.lite.sra
          [
            "ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun",
            style,
            run_accession[0..2],
            run_accession[0..5],
            run_accession,
            "#{run_accession}#{style_extension}"
          ].join('/')
        elsif options[:source] == :ebi
          unless style == 'fastq'
            raise "Unexpected format for download detected #{options[:format]} in combination with :source => :ebi. Require :fastq_gz"
          end
          ok_layouts = [:single, :paired1, :paired2]
          unless ok_layouts.include?(options[:layout])
            raise "Unexpected layout for download detected #{options[:layout]} in combination with :source => :ebi. Require on of #{ok_layouts.join(', ')}."
          end
          # e.g. for paired ended
          # ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR069/SRR069027/SRR069027_1.fastq.gz
          # e.g. for single end
          # ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR404/SRR404303/SRR404303.fastq.gz
          most = [
            'ftp://ftp.sra.ebi.ac.uk/vol1/',
            style,
            run_accession[0..5],
            run_accession,
          ]
          if options[:layout] == :single
            most.push "#{run_accession}#{style_extension}"
          elsif options[:layout] == :format1
            most.push "#{run_accession}_1#{style_extension}"
          elsif options[:layout] == :format2
            most.push "#{run_accession}_2#{style_extension}"
          end
          return most.join('/')
        end
      end
    end
  end
end
