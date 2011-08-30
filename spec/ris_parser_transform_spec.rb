# encoding: UTF-8
require 'spec_helper'
require 'parslet/rig/rspec'

describe 'ris parser transformer' do

  let(:parser)    { RisParser::RisParser.new           }
  let(:trans)     { RisParser::RisParserTransform.new }

  before(:all) do
    @doc = <<HERE
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

TY  - JOUR
AB  - Current conceptual models predict that changes in plant litter chemistry during decomposition are primarily regulated by both initial litter chemistry and the stage-or extent-of mass loss. Far less is known about how variations in decomposer community structure (e.g., resulting from different ecosystem management types) could influence litter chemistry during decomposition. Given the recent agricultural intensification occurring globally and the importance of litter chemistry in regulating soil organic matter storage, our objectives were to determine the potential effects of agricultural management on plant litter chemistry and decomposition rates, and to investigate possible links between ecosystem management, litter chemistry and decomposition, and decomposer community composition and activity. We measured decomposition rates, changes in litter chemistry, extracellular enzyme activity, microarthropod communities, and bacterial versus fungal relative abundance in replicated conventional-till, no-till, and old field agricultural sites for both corn and grass litter. After one growing season, litter decomposition under conventional-till was 20% greater than in old field communities. However, decomposition rates in no-till were not significantly different from those in old field or conventional-till sites. After decomposition, grass residue in both conventional- and no-till systems was enriched in total polysaccharides relative to initial litter, while grass litter decomposed in old fields was enriched in nitrogen-bearing compounds and lipids. These differences corresponded with differences in decomposer communities, which also exhibited strong responses to both litter and management type. Overall, our results indicate that agricultural intensification can increase litter decomposition rates, alter decomposer communities, and influence litter chemistry in ways that could have important and long-term effects on soil organic matter dynamics. We suggest that future efforts to more accurately predict soil carbon dynamics under different management regimes may need to explicitly consider how changes in litter chemistry during decomposition are influenced by the specific metabolic capabilities of the extant decomposer communities.
AU  - Wickings, K.
AU  - Grandy, A. S.
AU  - Reed, S.
AU  - Cleveland, C.
DO  - DOI 10.1007/s10533-010-9510-x
KW  - LTER pub
L1  - internal-pdf://Wickings_etal_2011_biogeochemistry-1074778885/Wickings_etal_2011_biogeochemistry.pdf
PY  - 2011
SP  - 365-379
ST  - Management intensity alters decomposition via biological pathways
T2  - Biogeochemistry
TI  - Management intensity alters decomposition via biological pathways
VL  - 104
ID  - 954
ER  - 


TY  - CHAP
A2  - Mendez-Vilas, A.
A2  - Diaz, J.
AB  - A major challenge in microbiology is to develop computing tools that can extract ecologically important information from digital images of populations and communities at single cell resolution, and analyze their structure in situ without cultivation. Several microbial ecologists, mathematicians, statisticians and computer scientists are addressing this challenge by developing a suite of software applications called CMEIAS (Center for Microbial Ecology Image Analysis System. The first release version of CMEIAS applies pattern recognition algorithms to classify all major plus several rare microbial morphotypes with 97% accuracy. Various CMEIAS upgrades feature image processing tools to segment objects within grayscale and color images before analysis, numerous measurement attributes for object analysis and classification, a multilinear cluster analysis application to optimize the size borders for subclassification of each morphotype into operational morphological units, tools to prepare images for extraction of spatial distribution data for pointpattern, quadrat-based and geostatistical analyses of microbial colonization to surfaces, and add-ins to compile, analyze, tabulate, graph and compute ecological statistics on CMEIAS data. When finalized, the various software applications and their documentations (refereed journal publications, thoroughly illustrated user manuals, help topic search files, audio-visual training tutorials with accompanying test images) are released as free downloads at our CMEIAS website http://cme.msu.edu/cmeias. Examples of ongoing research projects using CMEIAS applications include the autecological biogeography of superior endophytic rhizobial inoculants that promote grain production of rice crops, architectural analysis of aquatic microbial biofilms, and microscopical classification of human vaginal microflora in health and disease. This improved computing technology opens new opportunities of digital imaging applications where size, shape, abundance, luminosity, color, architecture and spatial location are important, thereby strengthening quantitative microscopy-based approaches to advance microbial ecology in situ and spatial scales directly relevant to individual microbes.
AU  - Dazzo, F.B.
CY  - Badajoz, Spain
KW  - LTER book section
L1  - internal-pdf://DazzoCmeiasChapterMicroscopySciTech2010final-3057371998/DazzoCmeiasChapterMicroscopySciTech2010final.pdf
PB  - Formatex Research Center
PY  - 2010
SP  - 1083-1090
ST  - CMEIAS digital microscopy and quantitative image analysis of microorganisms
SV  - 4
T2  - Microscopy: Science, Technology, Applications and Education
T3  - Formatex Research Center Microscopy Book Serie
TI  - CMEIAS digital microscopy and quantitative image analysis of microorganisms
VL  - 2
ID  - 945
ER  - 


HERE
  end

  it 'should recognize stanzas with types' do
    stanza = {:stanza => [{:type => "JOUR"}]}
    trans.apply(stanza)[:type].should ==  "JOUR"
  end

  it 'should recognize titles' do
    stanza = {:stanza => [{:title => 'long term studies'}]}
    trans.apply(stanza)[:title].should == 'long term studies'
  end

  it 'should recognize series_title' do
    stanza = {:stanza =>[{:series_title => 'boring books'}]}
    trans.apply(stanza)[:series_title].should == 'boring books'
  end

  it 'should collect authors' do
    stanza = {:stanza =>[{:author => "Zenone, T"}]}
    trans.apply(stanza)[:authors].should == ["Zenone, T"]
  end

  it 'should collect multiple authors' do
    stanza = {:stanza =>[{:author => "Zenone, T"}, {:author => "Robertson, G"}]}
    trans.apply(stanza)[:authors].should include "Zenone, T"
    trans.apply(stanza)[:authors].should include "Robertson, G"
  end

  it 'should keep authors in order' do
    stanza = {:stanza =>[{:author => "Zenone, T"}, {:author => "Robertson, G"}]}
    trans.apply(stanza)[:authors][0].should == "Zenone, T"
    trans.apply(stanza)[:authors][1].should == "Robertson, G"
  end

  it 'should deal with both types and authors' do
    stanza = {:stanza =>[{:type => 'JOUR'},
                          {:author => "Zenone, T"}, {:author => "Robertson, G"}]}
    trans.apply(stanza)[:authors].should include "Zenone, T"
    trans.apply(stanza)[:authors].should include "Robertson, G"
    trans.apply(stanza)[:type].should ==  "JOUR"
  end

  it 'should deal with an actual record' do
    result = trans.apply(parser.parse(@doc))
    result.size.should == 4
    first_record = result[0]
    first_record[:authors].should == ["Zenone, T.", "Chen, J.", "Deal, M.W.", "Wilske, B.", "Jasrotia, P.", "Xu, J.", "Bhardwaj, A.K.", "Hamilton, S. K.", "Robertson, G. P."]
    first_record[:type].should == "JOUR"
    first_record[:keyword].should == "GLBRC T4; LTER pub"
    first_record[:pdf].should == "internal-pdf://Zenone et al 2011 GCBB-0122663789/Zenone et al 2011 GCBB.pdf"
    first_record[:pub_year].should == "2011"
    first_record[:start_page].should == "DOI: 10.1111/j.1757-1707.2011.01098.x"
    first_record[:series_title].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation"
    first_record[:secondary_title].should == "Global Change Biology-Bioenergy"
    first_record[:title].should == "CO2 fluxes of transitional bioenergy crops: effect of land conversion during the first year of cultivation"
    first_record[:local_id].should == "930"

    second_record = result[1]
    second_record[:authors].should == ["Syswerda, S.P.", "Corbin, A.T.", "Mokma, D.L.", "Kravchenko, A. N.", "Robertson, G.P."]
    second_record[:type].should == "JOUR"
    second_record[:doi].should == "10.2136/sssaj2009.0414"
    second_record[:keyword].should == "LTER pub"
    second_record[:pdf].should == "internal-pdf://Syswerda etal. 2011-2756515844/Syswerda etal. 2011.pdf"
    second_record[:pub_year].should == "2011"
    second_record[:start_page].should == "92-101"
    second_record[:series_title].should == "Agricultural management and soil carbon storage in surface vs. deep layers"
    second_record[:secondary_title].should == "Soil Science Society of America Journal"
    second_record[:title].should == "Agricultural management and soil carbon storage in surface vs. deep layers"
    second_record[:volume].should == "75"
    second_record[:local_id].should == "907"
  end

  it "should be able to deal with a file" do
    parsed_output = parser.parse('@import spec/endnote/LTER.txt')
    result = trans.apply(parsed_output)
    result.count.should == 977
  end
end
