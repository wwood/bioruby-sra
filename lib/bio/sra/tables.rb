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
        self.primary_key = 'sra_ID'
        
        # Foreign keys
        belongs_to :submission, :foreign_key => 'submission_ID', :class_name => 'Submission', :primary_key => 'submission_ID'
        belongs_to :experiment, :foreign_key => 'experiment_ID', :class_name => 'Experiment', :primary_key => 'experiment_ID'
        belongs_to :study, :foreign_key => 'study_ID', :class_name => 'Study', :primary_key => 'study_ID'
        belongs_to :sample, :foreign_key => 'sample_ID', :class_name => 'Sample', :primary_key => 'sample_ID'
        belongs_to :run, :foreign_key => 'run_ID', :class_name => 'Run', :primary_key => 'run_ID'

        # named_scope for finding by an arbitrary SRA accession number e.g.
        # SRA.accession('SRA049809').all #=> Array of SRA objects that are part of the SRA049809 submission
        # SRA.accession('SRA049809').first #=> SRA object for the SRR404303 run (there is only 1 since this is a run accession)
        scope :accession, lambda {|accession|
          type = Bio::SRA::Accession.classify_accession_type(accession)
          {:conditions => {"#{type}_accession".to_sym => accession}}
        }
        
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

      # pp Bio::SRA::Tables::Submission.column_names
      # ["submission_ID",
      # "submission_alias",
      # "submission_accession",
      # "submission_comment",
      # "files",
      # "broker_name",
      # "center_name",
      # "lab_name",
      # "submission_date",
      # "sra_link",
      # "submission_url_link",
      # "xref_link",
      # "submission_entrez_link",
      # "ddbj_link",
      # "ena_link",
      # "submission_attribute",
      # "sradb_updated"]
      class Submission < Connection
        self.table_name = 'submission'
        self.primary_key = 'submission_ID'
        has_many :sras, :foreign_key => 'submission_ID', :class_name => 'SRA'
      end

      # pp Bio::SRA::Tables::Experiment.column_names
      # ["experiment_ID",
      # "bamFile",
      # "fastqFTP",
      # "experiment_alias",
      # "experiment_accession",
      # "broker_name",
      # "center_name",
      # "title",
      # "study_name",
      # "study_accession",
      # "design_description",
      # "sample_name",
      # "sample_accession",
      # "sample_member",
      # "library_name",
      # "library_strategy",
      # "library_source",
      # "library_selection",
      # "library_layout",
      # "targeted_loci",
      # "library_construction_protocol",
      # "spot_length",
      # "adapter_spec",
      # "read_spec",
      # "platform",
      # "instrument_model",
      # "platform_parameters",
      # "sequence_space",
      # "base_caller",
      # "quality_scorer",
      # "number_of_levels",
      # "multiplier",
      # "qtype",
      # "sra_link",
      # "experiment_url_link",
      # "xref_link",
      # "experiment_entrez_link",
      # "ddbj_link",
      # "ena_link",
      # "experiment_attribute",
      # "submission_accession",
      # "sradb_updated"]
      class Experiment < Connection
        self.table_name = 'experiment'
        self.primary_key = 'experiment_ID'
        has_many :sras, :foreign_key => 'experiment_ID', :class_name => 'SRA'
      end

      # pp Bio::SRA::Tables::Run.column_names
      # ["run_ID",
      # "bamFile",
      # "run_alias",
      # "run_accession",
      # "broker_name",
      # "instrument_name",
      # "run_date",
      # "run_file",
      # "run_center",
      # "total_data_blocks",
      # "experiment_accession",
      # "experiment_name",
      # "sra_link",
      # "run_url_link",
      # "xref_link",
      # "run_entrez_link",
      # "ddbj_link",
      # "ena_link",
      # "run_attribute",
      # "submission_accession",
      # "sradb_updated"]
      class Run < Connection
        self.table_name = 'run'
        self.primary_key = 'run_ID'
        has_many :sras, :foreign_key => 'run_ID', :class_name => 'SRA'
      end

      # pp Bio::SRA::Tables::Sample.column_names
      # ["sample_ID",
      # "sample_alias",
      # "sample_accession",
      # "broker_name",
      # "center_name",
      # "taxon_id",
      # "scientific_name",
      # "common_name",
      # "anonymized_name",
      # "individual_name",
      # "description",
      # "sra_link",
      # "sample_url_link",
      # "xref_link",
      # "sample_entrez_link",
      # "ddbj_link",
      # "ena_link",
      # "sample_attribute",
      # "submission_accession",
      # "sradb_updated"]
      class Sample < Connection
        self.table_name = 'sample'
        self.primary_key = 'sample_ID'
        has_many :sras, :foreign_key => 'sample_ID', :class_name => 'SRA'
      end
      
      # pp Bio::SRA::Tables::Study.column_names
      # ["study_ID",
      # "study_alias",
      # "study_accession",
      # "study_title",
      # "study_type",
      # "study_abstract",
      # "broker_name",
      # "center_name",
      # "center_project_name",
      # "study_description",
      # "related_studies",
      # "primary_study",
      # "sra_link",
      # "study_url_link",
      # "xref_link",
      # "study_entrez_link",
      # "ddbj_link",
      # "ena_link",
      # "study_attribute",
      # "submission_accession",
      # "sradb_updated"]
      class Study < Connection
        self.table_name = 'study'
        self.primary_key = 'study_ID'
        has_many :sras, :foreign_key => 'study_ID', :class_name => 'SRA'
      end

      # > pp Bio::SRA::Tables::SRAFt.column_names
      # ["SRR_bamFile",
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
      # "submission_date",
      # "sradb_updated"]
      class SRAFt < Connection
        self.table_name = 'sra_ft'
      end

      # pp Bio::SRA::Tables::SRAFtContent.column_names
      # ["docid",
      # "c0SRR_bamFile",
      # "c1SRX_bamFile",
      # "c2SRX_fastqFTP",
      # "c3run_ID",
      # "c4run_alias",
      # "c5run_accession",
      # "c6run_date",
      # "c7updated_date",
      # "c8spots",
      # "c9bases",
      # "c10run_center",
      # "c11experiment_name",
      # "c12run_url_link",
      # "c13run_entrez_link",
      # "c14run_attribute",
      # "c15experiment_ID",
      # "c16experiment_alias",
      # "c17experiment_accession",
      # "c18experiment_title",
      # "c19study_name",
      # "c20sample_name",
      # "c21design_description",
      # "c22library_name",
      # "c23library_strategy",
      # "c24library_source",
      # "c25library_selection",
      # "c26library_layout",
      # "c27library_construction_protocol",
      # "c28adapter_spec",
      # "c29read_spec",
      # "c30platform",
      # "c31instrument_model",
      # "c32instrument_name",
      # "c33platform_parameters",
      # "c34sequence_space",
      # "c35base_caller",
      # "c36quality_scorer",
      # "c37number_of_levels",
      # "c38multiplier",
      # "c39qtype",
      # "c40experiment_url_link",
      # "c41experiment_entrez_link",
      # "c42experiment_attribute",
      # "c43sample_ID",
      # "c44sample_alias",
      # "c45sample_accession",
      # "c46taxon_id",
      # "c47common_name",
      # "c48anonymized_name",
      # "c49individual_name",
      # "c50description",
      # "c51sample_url_link",
      # "c52sample_entrez_link",
      # "c53sample_attribute",
      # "c54study_ID",
      # "c55study_alias",
      # "c56study_accession",
      # "c57study_title",
      # "c58study_type",
      # "c59study_abstract",
      # "c60center_project_name",
      # "c61study_description",
      # "c62study_url_link",
      # "c63study_entrez_link",
      # "c64study_attribute",
      # "c65related_studies",
      # "c66primary_study",
      # "c67submission_ID",
      # "c68submission_accession",
      # "c69submission_comment",
      # "c70submission_center",
      # "c71submission_lab",
      # "c72submission_date",
      # "c73sradb_updated"]
      class SRAFtContent < Connection
        self.table_name = 'sra_ft_content'
      end

      # pp Bio::SRA::Tables::SRAFtSegDir.column_names
      # ["level", "idx", "start_block", "leaves_end_block", "end_block", "root"]
      class SRAFtSegDir < Connection
        self.table_name = 'sra_ft_segdir'
      end

      # pp Bio::SRA::Tables::SRAFtSegments.column_names
      # ["blockid", "block"]
      class SRAFtSegments < Connection
        self.table_name = 'sra_ft_segments'
      end
      
      # pp Bio::SRA::Tables::MetaInfo.column_names
      # ["name", "value"]
      class MetaInfo < Connection
        self.table_name = 'metaInfo'
      end
      
      # This table holds information about each of the columns
      # in this SRAmetadb database
      #
      # pp Bio::SRA::Tables::ColDesc.column_names
      # ["col_desc_ID",
      # "table_name",
      # "field_name",
      # "type",
      # "description",
      # "value_list",
      # "sradb_updated"]
      class ColDesc < Connection
        self.table_name = 'col_desc'
        self.primary_key = 'col_desc_ID'
        set_inheritance_column nil
      end
    end
  end
end
