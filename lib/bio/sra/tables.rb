module Bio
  module SRA
    module Tables
      # > pp Bio::SRA::Tables::SRA.column_names
      # ["sra_ID",
      # "SRR_bamFile",
      # "SRX_bamFile",
      # "SRX_fastqFTP",
      # "run_ID",
      # "run_alias",
      # "run_accession",
      # "run_date",
      # "updated_date",
      # "spots",
      # "bases",
      # "run_center",
      # "experiment_name",
      # "run_url_link",
      # "run_entrez_link",
      # "run_attribute",
      # "experiment_ID",
      # "experiment_alias",
      # "experiment_accession",
      # "experiment_title",
      # "study_name",
      # "sample_name",
      # "design_description",
      # "library_name",
      # "library_strategy",
      # "library_source",
      # "library_selection",
      # "library_layout",
      # "library_construction_protocol",
      # "adapter_spec",
      # "read_spec",
      # "platform",
      # "instrument_model",
      # "instrument_name",
      # "platform_parameters",
      # "sequence_space",
      # "base_caller",
      # "quality_scorer",
      # "number_of_levels",
      # "multiplier",
      # "qtype",
      # "experiment_url_link",
      # "experiment_entrez_link",
      # "experiment_attribute",
      # "sample_ID",
      # "sample_alias",
      # "sample_accession",
      # "taxon_id",
      # "common_name",
      # "anonymized_name",
      # "individual_name",
      # "description",
      # "sample_url_link",
      # "sample_entrez_link",
      # "sample_attribute",
      # "study_ID",
      # "study_alias",
      # "study_accession",
      # "study_title",
      # "study_type",
      # "study_abstract",
      # "center_project_name",
      # "study_description",
      # "study_url_link",
      # "study_entrez_link",
      # "study_attribute",
      # "related_studies",
      # "primary_study",
      # "submission_ID",
      # "submission_accession",
      # "submission_comment",
      # "submission_center",
      # "submission_lab",
      # "submission_date"]
      class SRA < Connection
        self.table_name = 'sra'
        belongs_to :submission, :foreign_key => 'submission_ID', :class_name => 'Submission', :primary_key => 'submission_ID'
  
        def self.find_by_accession(accession)
          type = Bio::SRA::Accession.classify_accession_type(accession)
          SRA.where("#{type}_accession" => accession).first
        end
  
        def self.find_all_by_accession(accession)
          type = Bio::SRA::Accession.classify_accession_type(accession)
          SRA.where("#{type}_accession" => accession).all
        end
        
        # URLs of all the runs in this project
        def study_download_urls(options = {})
          SRA.where(:study_accession => study_accession).all.collect do |run|
            run.download_url(options)
          end
        end
        
        # Return the URL where this SRA entry can be downloaded
        #        sraFileDir <- paste("ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByExp/", 
        #      sraType, "/", substring(sra_acc$experiment[i], 1, 
        #          3), "/", substring(sra_acc$experiment[i], 1, 
        #          6), "/", sra_acc$experiment[i], "/", sra_acc$run[i], 
        #      "/", sep = "")
        def download_url(options = {})
          Bio::SRA::Accession.run_download_url(run_accession, options)
        end
      end
      
      class Submission < Connection
        self.table_name = 'submission'
        self.primary_key = 'submission_ID'
        has_many :sras, :foreign_key => 'submission_ID', :class_name => 'SRA'
      end
    end
  end
end