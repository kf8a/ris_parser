# coding: utf-8

require 'spec_helper'
require 'parslet/rig/rspec'

describe 'ris parser' do
  let(:parser) { RisParser::RisParser.new }

  it 'should parse carriage returns and linefeeds' do
    parser.line.should parse("\n")
    parser.line.should parse("\r\n")
  end

  it 'should parse the start tag' do
    parser.start_tag.should parse("TY  - JOUR\n").as({:contents=>"JOUR"})
    parser.start_tag.should parse("TY  - JOUR\r\n").as({:contents=>"JOUR"})
    parser.start_tag.should_not parse("ER - \n")
  end

  it 'should consume an end tag' do
    parser.end_tag.should parse("ER  - \n").as("ER  - \n")
    parser.end_tag.should parse("ER  - \r\n").as("ER  - \r\n")
    parser.end_tag.should parse("ER  - \n\n").as("ER  - \n\n")
  end

  it 'should consume an abitrary tag' do
    parser.tag.should parse("TY  - ").as("TY  - ")
    parser.tag.should parse("T1  - ").as("T1  - ")
    parser.tag.should parse('L1  - ').as("L1  - ")

    parser.tag.should parse("AU  - ").as("AU  - ")
  end

  it 'should parse the arbitrary content' do
    parser.content.should parse("this is a test\n").as("this is a test\n")
    parser.content.should parse("last first\n").as("last first\n")
    parser.content.should parse("A sentence. Or two.\n").as("A sentence. Or two.\n")
    parser.content.should parse("A question?\n").as("A question?\n")
    parser.content.should parse("an EXCLAMATION!\n").as("an EXCLAMATION!\n")
    parser.content.should parse("A..ton of punctuation! does it WORK?\n").as("A..ton of punctuation! does it WORK?\n")
    parser.content.should parse("stage—or extent—of mass loss\n").as("stage—or extent—of mass loss\n")
    parser.content.should parse("Something with \\ || or //\n").as("Something with \\ || or //\n")
  end

  it 'should recognize an empty ris block' do
    parser.should parse("TY  - JOUR\nER  - \n").as([{:stanza=>{:type=>{:contents=>"JOUR"}}}])
    parser.should parse("TY  - BOOK\r\nER  - \r\n").as([{:stanza=>{:type=>{:contents=>"BOOK"}}}])
  end

  it 'should parse a one record ris stanza' do
    parser.should parse("TY  - JOUR\nAU  - last, first\nER  - \n").as([{:stanza=>[{:type=>{:contents=>"JOUR"}}, {:author=>{:contents=>"last, first\n"}}]}])
  end

  it 'should parse a multi record ris stanza' do
    parser.should parse("TY  - JOUR\nTI  - Title.\nAU  - last,f\nER  - \n")
    first_stanza = parser.parse("TY  - JOUR\nTI  - Title.\nAU  - last,f\nER  - \n")[0][:stanza]
    first_stanza[0][:type][:contents].should == "JOUR"
    first_stanza[1][:title][:contents].should == "Title.\n"
    first_stanza[2][:author][:contents].should == "last,f\n"
  end

  it 'should parse a multi line title record' do
    parser.record.should parse("TI  - The title\nand more\n")
    parser.record.parse("TI  - The title\nand more\n")[:title][:contents].should == "The title\nand more\n"
  end

  it 'should parse a mulit line abstract block' do
    doc = <<HERE
AB  - 1.Variation in species pools can affect plant diversity, but it remains unclear whether the magnitude of the response varies because of resource availability, community invasibility or other environmental factors, and whether colonization along environmental gradients reflects niche-based species sorting or neutral processes.

2.We hypothesized that unimodal diversity–productivity patterns in grasslands are dependent on species pools, with peak richness occurring at intermediate productivity due to species sorting associated with species traits. We used a seed-addition experiment to test the influence of immigration on plant species richness across multiple grasslands (old fields), each of which encompassed a broad range in productivity. We then tested whether species sorting occurs during colonization, if this varies with site productivity, and whether sorting patterns are associated with species traits 1 and 4 years after seed addition.
HERE
    parser.abstract.should parse(doc)
  end

  it 'should parse a multi record stanza with lines at the end' do
    parse_text = "TY  - JOUR\nTI  - Title\nAU  - last, first\nER  - \n\n\n"
    parser.should parse(parse_text)
    first_stanza = parser.parse(parse_text)[0][:stanza]
    first_stanza[0][:type][:contents].should == "JOUR"
    first_stanza[1][:title][:contents].should == "Title\n"
    first_stanza[2][:author][:contents].should == "last, first\n"
  end

  it 'should parse a full ris stanza' do
    doc = <<HERE
TY  - JOUR
AU  - Zenone, T.
AU  - Chen, J.
AU  - Deal, M.W.
AU  - Wilske, B.
AU  - Jasrotia, P.
AU  - Xu, J.
AU  - Bhardwaj, A.K.
AU  - Hamilton, S. K.
AU  - Robertson, G. P.
KW  - GLBRC T4; LTER pub
L1  - internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf
PY  - 2011
SP  - DOI: 10.1111/j.1757-1707.2011.01098.x
ST  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
T2  - Global Change Biology-Bioenergy
TI  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
ID  - 930
ER  -

HERE
    parser.should parse(doc)
    first_stanza = parser.parse(doc)[0][:stanza]
    first_stanza[0][:type][:contents].should == "JOUR"
    first_stanza[1][:author][:contents].should == "Zenone, T.\n"
    first_stanza[2][:author][:contents].should == "Chen, J.\n"
    first_stanza[3][:author][:contents].should == "Deal, M.W.\n"
    first_stanza[4][:author][:contents].should == "Wilske, B.\n"
    first_stanza[5][:author][:contents].should == "Jasrotia, P.\n"
    first_stanza[6][:author][:contents].should == "Xu, J.\n"
    first_stanza[7][:author][:contents].should == "Bhardwaj, A.K.\n"
    first_stanza[8][:author][:contents].should == "Hamilton, S. K.\n"
    first_stanza[9][:author][:contents].should == "Robertson, G. P.\n"
    first_stanza[10][:keyword][:contents].should == "GLBRC T4; LTER pub\n"
    first_stanza[11][:pdf][:contents].should == "internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf\n"
    first_stanza[12][:pub_year][:contents].should == "2011\n"
    first_stanza[13][:start_page][:contents].should == "DOI: 10.1111/j.1757-1707.2011.01098.x\n"
    first_stanza[14][:series_title][:contents].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation\n"
    first_stanza[15][:secondary_title][:contents].should == "Global Change Biology-Bioenergy\n"
    first_stanza[16][:title][:contents].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation\n"
    first_stanza[17][:local_id][:contents].should == "930\n"
  end

  it 'should parse multiple ris stanzas' do
    doc = <<HERE
TY  - JOUR
AU  - Zenone, T.
AU  - Chen, J.
AU  - Deal, M.W.
AU  - Wilske, B.
AU  - Jasrotia, P.
AU  - Xu, J.
AU  - Bhardwaj, A.K.
AU  - Hamilton, S. K.
AU  - Robertson, G. P.
KW  - GLBRC T4; LTER pub
L1  - internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf
PY  - 2011
SP  - DOI: 10.1111/j.1757-1707.2011.01098.x
ST  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
T2  - Global Change Biology-Bioenergy
TI  - CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation
ID  - 930
ER  -


TY  - JOUR
AU  - Syswerda, S.P.
AU  - Corbin, A.T.
AU  - Mokma, D.L.
AU  - Kravchenko, A. N.
AU  - Robertson, G.P.
DO  - 10.2136/sssaj2009.0414
KW  - LTER pub
L1  - internal-pdf://Syswerda etal. 2011-2756515844/Syswerda etal. 2011.pdf
PY  - 2011
SP  - 92-101
ST  - Agricultural management and soil carbon storage in surface vs. deep layers
T2  - Soil Science Society of America Journal
TI  - Agricultural management and soil carbon storage in surface vs. deep layers
VL  - 75
ID  - 907
ER  -

HERE
    parser.should parse(doc)
    first_stanza = parser.parse(doc)[0][:stanza]
    first_stanza[0][:type][:contents].should == "JOUR"
    first_stanza[1][:author][:contents].should == "Zenone, T.\n"
    first_stanza[2][:author][:contents].should == "Chen, J.\n"
    first_stanza[3][:author][:contents].should == "Deal, M.W.\n"
    first_stanza[4][:author][:contents].should == "Wilske, B.\n"
    first_stanza[5][:author][:contents].should == "Jasrotia, P.\n"
    first_stanza[6][:author][:contents].should == "Xu, J.\n"
    first_stanza[7][:author][:contents].should == "Bhardwaj, A.K.\n"
    first_stanza[8][:author][:contents].should == "Hamilton, S. K.\n"
    first_stanza[9][:author][:contents].should == "Robertson, G. P.\n"
    first_stanza[10][:keyword][:contents].should == "GLBRC T4; LTER pub\n"
    first_stanza[11][:pdf][:contents].should == "internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf\n"
    first_stanza[12][:pub_year][:contents].should == "2011\n"
    first_stanza[13][:start_page][:contents].should == "DOI: 10.1111/j.1757-1707.2011.01098.x\n"
    first_stanza[14][:series_title][:contents].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation\n"
    first_stanza[15][:secondary_title][:contents].should == "Global Change Biology-Bioenergy\n"
    first_stanza[16][:title][:contents].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation\n"
    first_stanza[17][:local_id][:contents].should == "930\n"

    second_stanza = parser.parse(doc)[1][:stanza]
    second_stanza[0][:type][:contents].should == "JOUR"
    second_stanza[1][:author][:contents].should == "Syswerda, S.P.\n"
    second_stanza[2][:author][:contents].should == "Corbin, A.T.\n"
    second_stanza[3][:author][:contents].should == "Mokma, D.L.\n"
    second_stanza[4][:author][:contents].should == "Kravchenko, A. N.\n"
    second_stanza[5][:author][:contents].should == "Robertson, G.P.\n"
    second_stanza[6][:doi][:contents].should == "10.2136/sssaj2009.0414\n"
    second_stanza[7][:keyword][:contents].should == "LTER pub\n"
    second_stanza[8][:pdf][:contents].should == "internal-pdf://Syswerda etal. 2011-2756515844/Syswerda etal. 2011.pdf\n"
    second_stanza[9][:pub_year][:contents].should == "2011\n"
    second_stanza[10][:start_page][:contents].should == "92-101\n"
    second_stanza[11][:series_title][:contents].should == "Agricultural management and soil carbon storage in surface vs. deep layers\n"
    second_stanza[12][:secondary_title][:contents].should == "Soil Science Society of America Journal\n"
    second_stanza[13][:title][:contents].should == "Agricultural management and soil carbon storage in surface vs. deep layers\n"
    second_stanza[14][:volume][:contents].should == "75\n"
    second_stanza[15][:local_id][:contents].should == "907\n"
  end

  it "should be able to deal with an actual file" do
    parser.should parse('@import spec/lter_endnote/LTER_pubs.txt')
    result = parser.parse('@import spec/lter_endnote/LTER_pubs.txt')
    result.should == {:file_name => "spec/lter_endnote/LTER_pubs.txt"}
  end

  it 'should be able to handle ET' do
    parser.record.should parse("ET  - 2nd\n").as({:et=>{:contents=>"2nd\n"}})
  end

  it 'should be able to handle underscores' do
    text_to_parse = "L1  - internal-pdf://Kravchenko_and_Robertson_2011-3126522656/Kravchenko_and_Robertson_2011.pdf\n"
    parser.record.should parse(text_to_parse).as({:pdf=>{:contents=>"internal-pdf://Kravchenko_and_Robertson_2011-3126522656/Kravchenko_and_Robertson_2011.pdf\n"}})
  end

  it 'should be able to handle parentheses' do
    text_to_parse = "ST  - Non-linear nitrous oxide (N2O) response to nitrogen fertilizer in on-farm corn crops of the us midwest\n"
    parser.record.should parse(text_to_parse).as({:series_title=>{:contents=>"Non-linear nitrous oxide (N2O) response to nitrogen fertilizer in on-farm corn crops of the us midwest\n"}})
  end

  it 'should be able to handle non-ascii dashes' do
    text_to_parse = "SP  - 1140–1152\n"
    parser.record.should parse(text_to_parse).as({:start_page=>{:contents=>"1140–1152\n"}})
  end

  it "should be able to handle names like O'Brien" do
    text_to_parse = "AU  - O'Brien, J.M.\n"
    parser.record.should parse(text_to_parse).as({:author=>{:contents=>"O'Brien, J.M.\n"}})
  end

  it "should be able to handle M3" do
    text_to_parse = "M3  - Ph. D.\n"
    parser.record.should parse(text_to_parse).as({:misc_3=>{:contents=>"Ph. D.\n"}})
  end

  it "should be able to deal with an ampersand" do
    text_to_parse = "T2  - Biomass & Bioenergy\n"
    parser.record.should parse(text_to_parse).as({:secondary_title=>{:contents=>"Biomass & Bioenergy\n"}})
  end

  it "should be able to deal with an equals" do
    text_to_parse = "UR  - http://www3.interscience.wiley.com/journal/123275861/abstract?CRETRY=1&SRETRY=0\n"
    parser.record.should parse(text_to_parse).as({:url=>{:contents=>"http://www3.interscience.wiley.com/journal/123275861/abstract?CRETRY=1&SRETRY=0\n"}})
  end

  it "should be able to deal with M1 tags" do
    parser.record.should parse("M1  - 1\n").as({:misc_1=>{:contents=>"1\n"}})
  end

  it "should be able to deal with an LB tag" do
    parser.record.should parse("LB  - 2010 prop\n").as({:lb=>{:contents=>"2010 prop\n"}})
  end

  it "should be able to deal with brackets" do
    text_to_parse = "SP  - 23. [online] URL: http://www.ecologyandsociety.org/vol15/iss4/art23/\n"
    parser.record.should parse(text_to_parse).as({:start_page=>{:contents=>"23. [online] URL: http://www.ecologyandsociety.org/vol15/iss4/art23/\n"}})
  end

  it "should be able to deal with AN tags" do
    text_to_parse = "AN  - ISI:000267130600026\n"
    parser.record.should parse(text_to_parse).as({:an=>{:contents=>"ISI:000267130600026\n"}})
  end

  it "should be able to deal with DA tags" do
    text_to_parse = "DA  - Jun\n"
    parser.record.should parse(text_to_parse).as({:da=>{:contents=>"Jun\n"}})
  end

  it "should be able to deal with angle brackets" do
    text_to_parse = "UR  - <Go to ISI>://000267130600026\n"
    parser.record.should parse(text_to_parse).as({:url=>{:contents=>"<Go to ISI>://000267130600026\n"}})
  end

  it "should be able to deal with umlauts" do
    text_to_parse = "L1  - internal-pdf://Lüpold etal ProcB 09-0340523577/Lüpold etal ProcB 09.pdf\n"
    parser.record.should parse(text_to_parse).as({:pdf=>{:contents=>"internal-pdf://Lüpold etal ProcB 09-0340523577/Lüpold etal ProcB 09.pdf\n"}})
  end

  it "should be able to deal with Y2 tags" do
    text_to_parse = "Y2  - December 07, 2009\n"
    parser.record.should parse(text_to_parse).as({:secondary_date=>{:contents=>"December 07, 2009\n"}})
  end

  it "should be able to deal with percentage signs" do
    contents = "We measured uptake length of (NO3)-N-15- in 72 streams in eight regions across the United States and Puerto Rico to develop quantitative predictive models on controls of NO3- uptake length. As part of the Lotic Intersite Nitrogen eXperiment II project, we chose nine streams in each region corresponding to natural (reference), suburban-urban, and agricultural land uses. Study streams spanned a range of human land use to maximize variation in NO3- concentration, geomorphology, and metabolism. We tested a causal model predicting controls on NO3- uptake length using structural equation modeling. The model included concomitant measurements of ecosystem metabolism, hydraulic parameters, and nitrogen concentration. We compared this structural equation model to multiple regression models which included additional biotic, catchment, and riparian variables. The structural equation model explained 79% of the variation in log uptake length (S-Wtot). Uptake length increased with specific discharge (Q/w) and increasing NO3- concentrations, showing a loss in removal efficiency in streams with high NO3- concentration. Uptake lengths shortened with increasing gross primary production, suggesting autotrophic assimilation dominated NO3- removal. The fraction of catchment area as agriculture and suburban urban land use weakly predicted NO3- uptake in bivariate regression, and did improve prediction in a set of multiple regression models. Adding land use to the structural equation model showed that land use indirectly affected NO3- uptake lengths via directly increasing both gross primary production and NO3- concentration. Gross primary production shortened SWtot, while increasing NO3- lengthened SWtot resulting in no net effect of land use on NO3- removal.\n"
    text_to_parse = "AB  - " + contents
    parser.record.should parse(text_to_parse).as({:abstract=>{:contents=>contents}})
  end

  it "should be able to deal with quotation marks" do
    text_to_parse = %Q{ST  - A mini-review of the "feeding specialization/physiological efficiency" hypothesis: 50 years of difficulties, and strong support from the North American Lauraceae-specialist, Papilio troilus (Papilionidae: Lepidoptera)\n}
    parser.record.should parse(text_to_parse).as({:series_title=>{:contents=>"A mini-review of the \"feeding specialization/physiological efficiency\" hypothesis: 50 years of difficulties, and strong support from the North American Lauraceae-specialist, Papilio troilus (Papilionidae: Lepidoptera)\n"}})
  end

  it "should be able to deal with RN tags" do
    text_to_parse = "RN  - I did a case study of tart cherry production in the Grand Traverse Region. The LTER data was used as background. It included both archival and historical data that was used to explore the history of Michigan fruit
production more broadly. As you probably know, MI fruit production began in the southern portion of the state many decades before planting was initiated in the northwest. And, it was the southern fruit growers who initially drove a series of state laws and regulations governing fruit production, pest management, and product standards. These growers were also influential in the development of Michigan State University and they influenced what its role would be with respect to fruit production across the state. In addition, the LTER data provided a means for putting the sociocultural setting of the Northwest cherries into perspective, not only within Michigan, but also within the larger political economy of the U.S. agrifood sector.
"
    parser.record.should parse(text_to_parse).as({:rn=>{:contents=>"I did a case study of tart cherry production in the Grand Traverse Region. The LTER data was used as background. It included both archival and historical data that was used to explore the history of Michigan fruit\nproduction more broadly. As you probably know, MI fruit production began in the southern portion of the state many decades before planting was initiated in the northwest. And, it was the southern fruit growers who initially drove a series of state laws and regulations governing fruit production, pest management, and product standards. These growers were also influential in the development of Michigan State University and they influenced what its role would be with respect to fruit production across the state. In addition, the LTER data provided a means for putting the sociocultural setting of the Northwest cherries into perspective, not only within Michigan, but also within the larger political economy of the U.S. agrifood sector.\n"}})
  end

  it "should be able to deal with extra blank lines" do
    doc = <<HERE
TY  - JOUR
KW  - LTER pub

L1  - internal-pdf://Blackwood et al. 2006 SBB-1414257209/Blackwood et al. 2006 SBB.pdf
ER  -

HERE
    parser.should parse(doc).as([{:stanza=>[{:type=>{:contents=>"JOUR"}}, {:keyword=>{:contents=>"LTER pub\n\n"}}, {:pdf=>{:contents=>"internal-pdf://Blackwood et al. 2006 SBB-1414257209/Blackwood et al. 2006 SBB.pdf\n"}}]}])
  end

  it "should be able to deal with hashes" do
    text_to_parse = "PB  - ASA-CSSA-SSSA Special Publication #64\n"
    parser.record.should parse(text_to_parse).as({:publisher=>{:contents=>"ASA-CSSA-SSSA Special Publication #64\n"}})
  end

  it "should be able to deal with @ signs" do
    text_to_parse = "AD  - Michigan State Univ, Dept Crop & Soil Sci, Hickory Corners, MI 49060 USA. Michigan State Univ, WK Kellogg Biol Stn, Hickory Corners, MI 49060 USA. Michigan State Univ, Dept Crop & Soil Sci, E Lansing, MI 48824 USA.
Robertson, GP, Michigan State Univ, Dept Crop & Soil Sci, Hickory Corners, MI 49060 USA.
robertson@kbs.msu.edu\n"
    parser.record.should parse(text_to_parse).as({:address=>{:contents=>"Michigan State Univ, Dept Crop & Soil Sci, Hickory Corners, MI 49060 USA. Michigan State Univ, WK Kellogg Biol Stn, Hickory Corners, MI 49060 USA. Michigan State Univ, Dept Crop & Soil Sci, E Lansing, MI 48824 USA.\nRobertson, GP, Michigan State Univ, Dept Crop & Soil Sci, Hickory Corners, MI 49060 USA.\nrobertson@kbs.msu.edu\n"}})
  end

  it "should be able to deal with J2" do
    text_to_parse = "J2  - Science\n"
    parser.record.should parse(text_to_parse).as({:journal=>{:contents=>"Science\n"}})
  end

  it "should be able to deal with LA tags" do
    text_to_parse = "LA  - English\n"
    parser.record.should parse(text_to_parse).as({:language=>{:contents=>"English\n"}})
  end

  it "should be able to deal with T3 tags" do
    text_to_parse = "T3  - Management of Carbon in Tropical Soils Under Global Change: Science, Practice and Policy\n"
    parser.record.should parse(text_to_parse).as({:title_series=>{:contents=>"Management of Carbon in Tropical Soils Under Global Change: Science, Practice and Policy\n"}})
  end

  it "should be able to deal with CT tags" do
    text_to_parse = "CT  - This is an unpublished title\n"
    parser.record.should parse(text_to_parse).as({:title=>{:contents=>"This is an unpublished title\n"}})
  end

  it "should be able to deal with Y1 tags" do
    text_to_parse = "Y1  - A primary date\n"
    parser.record.should parse(text_to_parse).as({:primary_date=>{:contents=>"A primary date\n"}})
  end

  it "should be able to deal with RP tags" do
    text_to_parse = "RP  - IN FILE\n"
    parser.record.should parse(text_to_parse).as({:reprint_status=>{:contents=>"IN FILE\n"}})
  end

  it "should be able to deal with J1 tags" do
    text_to_parse = "J1  - Periodical Name\n"
    parser.record.should parse(text_to_parse).as({:journal=>{:contents=>"Periodical Name\n"}})
  end

  it "should be able to deal with U1 tags" do
    text_to_parse = "U1  - Info defined by user\n"
    parser.record.should parse(text_to_parse).as({:user_definable1=>{:contents=>"Info defined by user\n"}})
  end

  it "should be able to deal with U2 tags" do
    text_to_parse = "U2  - Info defined by user\n"
    parser.record.should parse(text_to_parse).as({:user_definable2=>{:contents=>"Info defined by user\n"}})
  end

  it "should be able to deal with U3 tags" do
    text_to_parse = "U3  - Info defined by user\n"
    parser.record.should parse(text_to_parse).as({:user_definable3=>{:contents=>"Info defined by user\n"}})
  end

  it "should be able to deal with U4 tags" do
    text_to_parse = "U4  - Info defined by user\n"
    parser.record.should parse(text_to_parse).as({:user_definable4=>{:contents=>"Info defined by user\n"}})
  end

  it "should be able to deal with U5 tags" do
    text_to_parse = "U5  - Info defined by user\n"
    parser.record.should parse(text_to_parse).as({:user_definable5=>{:contents=>"Info defined by user\n"}})
  end

  it "should be able to deal with AV tags" do
    text_to_parse = "AV  - This is available\n"
    parser.record.should parse(text_to_parse).as({:availability=>{:contents=>"This is available\n"}})
  end

  it "should be able to deal with L3 tags" do
    text_to_parse = "L3  - Some related records\n"
    parser.record.should parse(text_to_parse).as({:related_records=>{:contents=>"Some related records\n"}})
  end

  it "should be able to deal with L4 tags" do
    text_to_parse = "L4  - /link/to/images\n"
    parser.record.should parse(text_to_parse).as({:images=>{:contents=>"/link/to/images\n"}})
  end

  it "should be able to deal with BT tags" do
    text_to_parse = "BT  - Another Title\n"
    parser.record.should parse(text_to_parse).as({:secondary_title=>{:contents=>"Another Title\n"}})
  end

  it "should be able to deal with ED tags" do
    text_to_parse = "ED  - An Editor or Secondary Author\n"
    parser.record.should parse(text_to_parse).as({:secondary_author=>{:contents=>"An Editor or Secondary Author\n"}})
  end

  it "should be able to deal with CP tags" do
    text_to_parse = "CP  - Issue number\n"
    parser.record.should parse(text_to_parse).as({:issue=>{:contents=>"Issue number\n"}})
  end

  it "should be able to deal with M2 tags" do
    text_to_parse = "M2  - More miscellany\n"
    parser.record.should parse(text_to_parse).as({:misc_2=>{:contents=>"More miscellany\n"}})
  end

  it "should handle all standard RIS tags" do
    should_be_a_valid_record_tag('T1')
    should_be_a_valid_record_tag('TI')
    should_be_a_valid_record_tag('CT')
    should_be_a_valid_record_tag('BT')
    should_be_a_valid_record_tag('A1')
    should_be_a_valid_record_tag('A2')
    should_be_a_valid_record_tag('AU')
    should_be_a_valid_record_tag('Y1')
    should_be_a_valid_record_tag('PY')
    should_be_a_valid_record_tag('N1')
    should_be_a_valid_record_tag('KW')
    should_be_a_valid_record_tag('RP')
    should_be_a_valid_record_tag('SP')
    should_be_a_valid_record_tag('EP')
    should_be_a_valid_record_tag('JF')
    should_be_a_valid_record_tag('JO')
    should_be_a_valid_record_tag('JA')
    should_be_a_valid_record_tag('J1')
    should_be_a_valid_record_tag('J2')
    should_be_a_valid_record_tag('VL')
    should_be_a_valid_record_tag('IS')
    should_be_a_valid_record_tag('T2')
    should_be_a_valid_record_tag('CY')
    should_be_a_valid_record_tag('PB')
    should_be_a_valid_record_tag('U1')
    should_be_a_valid_record_tag('U5')
    should_be_a_valid_record_tag('T3')
    should_be_a_valid_record_tag('N2')
    should_be_a_valid_record_tag('SN')
    should_be_a_valid_record_tag('AV')
    should_be_a_valid_record_tag('M1')
    should_be_a_valid_record_tag('M3')
    should_be_a_valid_record_tag('AD')
    should_be_a_valid_record_tag('UR')
    should_be_a_valid_record_tag('L1')
    should_be_a_valid_record_tag('L2')
    should_be_a_valid_record_tag('L3')
    should_be_a_valid_record_tag('L4')
  end

  def should_be_a_valid_record_tag(tag)
    text_to_parse = tag + "  - interesting content\n"
    parser.record.should parse(text_to_parse)
  end

  it "should be able to parse an example from the RIS website" do
    doc = <<HERE
TY  - JOUR
A1  - Baldwin,S.A.
A1  - Fugaccia,I.
A1  - Brown,D.R.
A1  - Brown,L.V.
A1  - Scheff,S.W.
T1  - Blood-brain barrier breach following
cortical contusion in the rat
JO  - J.Neurosurg.
Y1  - 1996
VL  - 85
SP  - 476
EP  - 481
RP  - Not In File
KW  - cortical contusion
KW  - blood-brain barrier
KW  - horseradish peroxidase
KW  - head trauma
KW  - hippocampus
KW  - rat
N2  - Adult Fisher 344 rats were subjected to a unilateral impact to the dorsal cortex above the hippocampus at 3.5 m/sec with a 2 mm cortical depression. This caused severe cortical damage and neuronal loss in hippocampus subfields CA1, CA3 and hilus. Breakdown of the blood-brain barrier (BBB) was assessed by injecting the protein horseradish peroxidase (HRP) 5 minutes prior to or at various times following injury (5 minutes, 1, 2, 6, 12 hours, 1, 2, 5, and 10 days). Animals were killed 1 hour after HRP injection and brain sections were reacted with diaminobenzidine to visualize extravascular accumulation of the protein. Maximum staining occurred in animals injected with HRP 5 minutes prior to or 5 minutes after cortical contusion. Staining at these time points was observed in the ipsilateral hippocampus. Some modest staining occurred in the dorsal contralateral cortex near the superior sagittal sinus. Cortical HRP stain gradually decreased at increasing time intervals postinjury. By 10 days, no HRP stain was observed in any area of the brain. In the ipsilateral hippocampus, HRP stain was absent by 3 hours postinjury and remained so at the 6- and 12- hour time points. Surprisingly, HRP stain was again observed in the ipsilateral hippocampus 1 and 2 days following cortical contusion, indicating a biphasic opening of the BBB following head trauma and a possible second wave of secondary brain damage days after the contusion injury. These data indicate regions not initially destroyed by cortical impact, but evidencing BBB breach, may be accessible to neurotrophic factors administered intravenously both immediately and days after brain trauma.
ER  -

HERE
    parser.should parse(doc)
  end

  it "should be able to parse the second sample from the RIS website" do
    doc = <<HERE
TY  - PAT
A1  - Burger,D.R.
A1  - Goldstein,A.S.
T1  - Method of detecting AIDS virus infection
Y1  - 1990/2/27
VL  - 877609
IS  - 4,904,581
RP  - Not In File
A2  - Epitope,I.
CY  - OR
PB  - 4,629,783
KW  - AIDS
KW  - virus
KW  - infection
KW  - antigens
Y2  - 1986/6/23
M1  - G01N 33/569 G01N 33/577
M2  - 435/5 424/3 424/7.1 435/7 435/29 435/32 435/70.21 435/240.27 435/172.2 530/387 530/808 530/809 935/110
N2  - A method is disclosed for detecting the presence of HTLV III infected cells in a medium. The method comprises contacting the medium with monoclonal antibodies against an antigen produced as a result of the infection and detecting the binding of the antibodies to the antigen. The antigen may be a gene product of the HTLV III virus or may be bound to such gene product. On the other hand the antigen may not be a viral gene product but may be produced as a result of the infection and may further be bound to a lymphocyte. The medium may be a human body fluid or a culture medium. A particular embodiment of the present method involves a method for determining the presence of a AIDS virus in a person. The method comprises combining a sample of a body fluid from the person with a monoclonal antibody that binds to an antigen produced as a result of the infection and detecting the binding of the monoclonal antibody to the antigen. The presence of the binding indicates the presence of a AIDS virus infection. Also disclosed are novel monoclonal antibodies, noval compositions of matter, and novel diagnostic kits
ER  -

HERE
    parser.should parse(doc)
  end

  it "should be able to parse the third sample from the RIS website" do
    doc = <<HERE
TY  - CONF
A1  - Catania,J.
A1  - Coates,T.
A1  - Kegeles,S.
A1  - Peterson,J.
A1  - Marin,B.
A1  - Fullilove,M.
T1  - Predicting risk behavior with the AIDS risk reduction model (ARRM) in a random household probability sample of San Franciscans: the "AMEN" study
Y1  - 1990///6th Annual
VL  - 6
SP  - 318
EP  - 318
RP  - Not In File
CY  - Detroit MI
KW  - risk
KW  - AIDS
KW  - models
KW  - sexual behavior
KW  - HIV
KW  - condoms
KW  - heterosexual
KW  - bisexual
KW  - ethnicity
KW  - women
T3  - International Conference on AIDS 6
Y2  - 1990/6/20
M1  - 1
N1  - OBJECTIVE: Data from the AIDS In Multi-Ethnic Neighborhoods survey are used to test Stages 1 & 3 of ARRM (a three stage process model of sexual risk behavior change; Catania, Kegeles, & Coates, 1990). Stage 1 analyses examine predictors of labeling one's sexual behavior in terms of HIV risk; Stage 3 concerns predictors of sexual behavior (e.g., condom use) (Stage 2 was not assessed in this first wave of the study but will be examined in wave 2). METHODS: Data were collected in a random household probability study of 1,781 white (41%), black (26%), and Hispanic (25%) (8% Other), unmarried respondents, aged 20-44, residing in selected "high risk" census tracts of San Francisco (Heterosexual = 83%, Homosexual = 13%, Bisexual = 4%). Labeling defined as making an accurate or inaccurate assessment of one's risk for HIV based on prior and current sexual practices. The behavioral outcome is frequency of condom use averaged across sexual partners for the past year. RESULTS: Multiple regression (Logistic & LSQ) analyses indicate that, 1) Accurate labeling of high risk behavior is related to high susceptibility beliefs (Imp. Chi Sq. =,92.46, p less than .0001), but unrelated to knowing someone with AIDS; gay relative to heterosexual men (p less than .03), and Hispanics compared to whites (p less than .01) were more likely to accurately label their behavior, 2) Greater condom use during vaginal or anal intercourse is significantly related to better sexual communication skills, higher perceived benefits and lower costs of condom use, but unrelated to religiosity, self-efficacy, and ethnicity (R's range from .50 - .66); these latter results are substantially the same for men and women, and heterosexuals and gay men. CONCLUSION: The findings 1) suggest the ARRM model is applicable to most social groups, 2) underscore the importance of interventions that enhance communication skills and teach methods of facilitating sexual enjoyment of condoms
ER  -

HERE
    parser.should parse(doc)
  end

  it "should be able to parse the fourth, fifth, and sixth samples from the RIS website" do
    doc = <<HERE
TY  - RPRT
A1  - Esparza,J.
T1  - Report of a WHO workshop on the measurement and significance of neutralizing antibody to HIV and SIV, London, 3-5 October 1988
Y1  - 1990
VL  - 4
SP  - 269
EP  - 275
RP  - Not In File
CY  - San Francisco CA
PB  - UC Berkeley
KW  - HIV
KW  - SIV
KW  - AIDS
T3  - World Health Organisation Global Programme on AIDS
ER  -

TY  - CHAP
A1  - Franks,L.M.
T1  - Preface by an AIDS Victim
Y1  - 1991
VL  - 10
SP  - vii
EP  - viii
RP  - Not In File
T2  - Cancer, HIV and AIDS.
CY  - Berkeley CA
PB  - Berkeley Press
KW  - HIV
KW  - AIDS
M1  - 1
M2  - 1
SN  - 0-679-40110-5
ER  -

TY  - CASE
A1  - Cary,A.
A1  - Friedenrich,W.
T1  - Redman v. State of California
Y1  - 1988/10/7
VL  - 201
IS  - 32
SP  - 220
EP  - 240
RP  - Not In File
CY  - ATLA Law Reporter
PB  - San Diego County 45th Judicial District, California
KW  - AIDS
KW  - litigation
KW  - AIDS litigation
KW  - rape
U1  - ISSN 0456-8125
N1  - Raped inmate can press case against officials for contracting AIDS
ER  -

HERE
    parser.should parse(doc)
  end


  it 'should parse one actual file' do
    parser.should parse('@import spec/endnote/LTER.txt')
  end

end
