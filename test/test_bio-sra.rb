require 'helper'
require 'pp'

class TestBioSraTables < Test::Unit::TestCase
  include Bio::SRA::Tables
  
  should "test find by accession" do
    # 1.9.3-p0 :014 > p Bio::SRA::SRA.find_by_sra_ID('2.0')
    #<Bio::SRA::SRA sra_ID: 2.0, SRR_bamFile: nil, SRX_bamFile: nil, SRX_fastqFTP: nil, run_ID: 2.0, run_alias: "2008-09-12.Bsu168-Lane5", run_accession: "DRR000002", run_date: "2008-09-12", updated_date: "2011-03-04", spots: 8316737, bases: 598805064, run_center: "NIG", experiment_name: "BSU168_SEP08", run_url_link: nil, run_entrez_link: nil, run_attribute: "notes: repackaged seq prb sig2", experiment_ID: 2.0, experiment_alias: "BSU168_SEP08", experiment_accession: "DRX000002", experiment_title: "B. subtilis subsp. subtilis genome resequencing Sep...", study_name: "Resequence B. subtilis 168", sample_name: "B. subtilis 168 DNA extracted Aug 2008", design_description: "Randomly fragmented by ultrasonic waves.", library_name: "B.subtilis subtilis 168 Genomic DNA fragments, isol...", library_strategy: "WGS", library_source: "GENOMIC", library_selection: "RANDOM", library_layout: "PAIRED - NOMINAL_LENGTH: 153; NOMINAL_SDEV: 29.528;...", library_construction_protocol: "The DNA is purified through the ultracentrifugation...", adapter_spec: nil, read_spec: "READ_INDEX: 0; READ_CLASS: Application Read; READ_T...", platform: "ILLUMINA", instrument_model: "Illumina Genome Analyzer II", instrument_name: nil, platform_parameters: "INSTRUMENT_MODEL: Illumina Genome Analyzer II; CYCL...", sequence_space: "Base Space", base_caller: "Solexa primary analysis", quality_scorer: "Solexa primary analysis", number_of_levels: 80, multiplier: "1", qtype: "other", experiment_url_link: nil, experiment_entrez_link: nil, experiment_attribute: nil, sample_ID: 2.0, sample_alias: "B. subtilis 168 DNA extracted Aug 2008", sample_accession: "DRS000002", taxon_id: 224308, common_name: "Bacillus subtilis subsp. subtilis str. 168", anonymized_name: nil, individual_name: nil, description: "Genomic DNA from Bacillus subtilis subsp. subtilis ...", sample_url_link: nil, sample_entrez_link: nil, sample_attribute: "strain: str. 168: ", study_ID: 2.0, study_alias: "Resequence B. subtilis 168", study_accession: "DRP000002", study_title: "Whole genome resequencing of Bacillus subtilis subs...", study_type: "Whole Genome Sequencing", study_abstract: "Whole genome resequencing of B. subtilis subtilis 1...", center_project_name: "Whole genome resequencing of B. subtilis subtilis 1...", study_description: "Whole genome resequencing of B. subtilis subtilis 1...", study_url_link: nil, study_entrez_link: "pubmed: 20398357", study_attribute: nil, related_studies: "DB: bioproject; ID: 39275; LABEL: PRJDA39275", primary_study: "true", submission_ID: 2.0, submission_accession: "DRA000002", submission_comment: "Bacillus subtilis subsp. subtilis strain 168 resequ...", submission_center: "KEIO", submission_lab: "Bioinformatics Lab.", submission_date: "2009-07-09", sradb_updated: "2012-04-04 20:00:12">

    # test experiment_accession
    assert_equal 'DRR000002', SRA.find_by_accession('DRX000002').run_accession
    assert_equal 'DRR000002', SRA.find_by_accession('DRP000002').run_accession
    assert_equal 'DRR000002', SRA.find_by_accession('DRA000002').run_accession
    assert_equal 'DRR000002', SRA.find_by_accession('DRS000002').run_accession
    assert_equal 'DRR000002', SRA.find_by_accession('DRR000002').run_accession
  end
  
  should "find all runs from a single project" do
    assert_equal ['ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/litesra/DRR/DRR000/DRR000002/DRR000002.lite.sra'],
      SRA.find_by_accession('DRR000002').study_download_urls
    
    three = SRA.find_by_accession('DRR000003').study_download_urls.sort
    assert_equal 9, three.length
    assert_equal 'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/litesra/DRR/DRR000/DRR000004/DRR000004.lite.sra',
      three[1]
      
    three = SRA.find_by_accession('DRR000003').study_download_urls(:format => :sra).sort
    assert_equal 9, three.length
    assert_equal 'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/DRR/DRR000/DRR000004/DRR000004.sra',
      three[1]
  end
  
  should "find all by accession" do
    assert_equal 9, SRA.find_all_by_accession('DRP000003').uniq.length
    assert_equal 'DRR000004', SRA.find_all_by_accession('DRP000003').collect{|s| s.run_accession}.sort[1]
  end
  
  should "sra should have foreign key to submission" do
    assert_equal 'KEIO', SRA.find_by_accession('DRP000001').submission.center_name
    sras = Submission.find(1).sras
    assert_equal 1, sras.length
    assert_equal 'DRP000001', sras[0].study_accession
    
    sras = Submission.find(3).sras
    assert_equal 9, sras.length
    assert_equal 'DRP000003', sras[0].study_accession
  end
end


class TestBioSraTables < Test::Unit::TestCase
  include Bio::SRA
  
  should "test get regular run accession" do
    assert_equal 'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/litesra/DRR/DRR000/DRR000002/DRR000002.lite.sra',
      Accession.run_download_url('DRR000002')
    assert_equal 'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/DRR/DRR000/DRR000002/DRR000002.sra',
      Accession.run_download_url('DRR000002', :format => :sra)
    assert_equal 'ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/litesra/DRR/DRR000/DRR000002/DRR000002.lite.sra',
      Accession.run_download_url('DRR000002', :format => :sralite)

    assert_raise RuntimeError do
      Accession.run_download_url('DRP000002')
    end
    assert_raise RuntimeError do
      Accession.run_download_url('DRR000002', :format => :notaformat)
    end
  end
end