# coding: utf-8

require 'parslet'

module RisParser
  class RisParser < Parslet::Parser

    rule(:space)      { match('\s') }
    rule(:space?)     { space.maybe }

    rule(:eof)        { any.absnt? }
    rule(:lf)         { match('\n') }
    rule(:cr)         { match('\r') }
    rule(:line)       { lf | cr >> lf }
    rule(:number)     { match('\d').repeat(1) }

    rule(:start_tag)  { str('TY  - ') >> match('[A-Z]').repeat.as(:contents) >> line }
    rule(:end_tag)    { str('ER  -') >> space? >> line.repeat(1) }

    rule(:author_id)    { str('AU') | str('A1') }
    rule(:author)       { author_id >> tag_marker >> contents.as(:author)}
    rule(:secondary_author_id) { str('A2') | str('ED') }
    rule(:secondary_author) { secondary_author_id >> tag_marker >> contents.as(:secondary_author) }
    rule(:editor)       { str('A3') >> tag_marker >> contents.as(:editor)}
    rule(:title_id)     { str('TI') | str('T1') | str('CT') }
    rule(:title)        { title_id  >> tag_marker >> contents.as(:title) }
    rule(:second_title) { (str('T2') | str('BT')) >> tag_marker >> contents.as(:secondary_title) }
    rule(:title_series) { str('T3') >> tag_marker >> contents.as(:title_series) }
    rule(:series_title) { str('ST') >> tag_marker >> contents.as(:series_title) }
    rule(:doi)          { str('DO') >> tag_marker >> contents.as(:doi) }
    rule(:local_id)     { str('ID') >> tag_marker >> contents.as(:local_id) }
    rule(:pdf)          { str('L1') >> tag_marker >> contents.as(:pdf) }
    rule(:kw)           { str('KW') >> tag_marker >> contents.as(:keyword) }
    rule(:primary_date) { str('Y1') >> tag_marker >> contents.as(:primary_date) }
    rule(:pub_year)     { str('PY') >> tag_marker >> contents.as(:pub_year) }
    rule(:reprint_status) {str('RP')>> tag_marker >> contents.as(:reprint_status) }
    rule(:abstract_id)  { str('N2') | str('AB')}
    rule(:abstract)     { abstract_id >> tag_marker >> contents.as(:abstract) }
    rule(:note)         { str('N1') >> tag_marker >> contents.as(:note) }
    rule(:url)          { str('UR') >> tag_marker >> contents.as(:url) }
    rule(:full_text)    { str('L2') >> tag_marker >> contents.as(:full_text) }
    rule(:volume)       { str('VL') >> tag_marker >> contents.as(:volume) }
    rule(:series)       { str('SV') >> tag_marker >> contents.as(:series) }
    rule(:issue_id)     { str('IS') | str('CP') }
    rule(:issue)        { issue_id >> tag_marker >> contents.as(:issue) }
    rule(:range_text)   { match['^[\-\r\n]'].repeat(1).as(:contents) }
    rule(:page_range)   { range_text.as(:start_page) >> match['[\-\u2013\u2014\u2012]'] >> range_text.as(:end_page) }
    rule(:pages)        { page_range | range_text.as(:start_page) }
    rule(:start_page)   { str('SP') >> tag_marker >> pages >> line }
    rule(:end_page)     { str('EP') >> tag_marker >> contents.as(:end_page) }
    rule(:isbn)         { str('SN') >> tag_marker >> contents.as(:isbn) }
    rule(:city)         { str('CY') >> tag_marker >> contents.as(:city) }
    rule(:address)      { str('AD') >> tag_marker >> contents.as(:address) }
    rule(:publisher)    { str('PB') >> tag_marker >> contents.as(:publisher) }
    rule(:journal_id)   { str('JA') | str('JF') | str('JO') | str('J1') | str('J2') }
    rule(:journal)      { journal_id >> tag_marker >> contents.as(:journal) }
    rule(:language)     { str('LA') >> tag_marker >> contents.as(:language) }
    rule(:misc_1)       { str('M1') >> tag_marker >> contents.as(:misc_1) }
    rule(:misc_2)       { str('M2') >> tag_marker >> contents.as(:misc_2) }
    rule(:misc_3)       { str('M3') >> tag_marker >> contents.as(:misc_3) }
    rule(:secondary_date) { str('Y2') >> tag_marker >> contents.as(:secondary_date) }
    rule(:user_definable1) { str('U1') >> tag_marker >> contents.as(:user_definable1) }
    rule(:user_definable2) { str('U2') >> tag_marker >> contents.as(:user_definable2) }
    rule(:user_definable3) { str('U3') >> tag_marker >> contents.as(:user_definable3) }
    rule(:user_definable4) { str('U4') >> tag_marker >> contents.as(:user_definable4) }
    rule(:user_definable5) { str('U5') >> tag_marker >> contents.as(:user_definable5) }
    rule(:availability) { str('AV') >> tag_marker >> contents.as(:availability) }
    rule(:related_records) { str('L3') >> tag_marker >> contents.as(:related_records) }
    rule(:images)       { str('L4') >> tag_marker >> contents.as(:images) }

    #Naively implemented tags
    rule(:an)           { str('AN') >> tag_marker >> contents.as(:an) }
    rule(:da)           { str('DA') >> tag_marker >> contents.as(:da) }
    rule(:et)           { str('ET') >> tag_marker >> contents.as(:et) }
    rule(:lb)           { str('LB') >> tag_marker >> contents.as(:lb) }
    rule(:rn)           { str('RN') >> tag_marker >> contents.as(:rn) }


    rule(:tag_id)     { match['A-Z'] >> match['0-9A-Z'] }

    rule(:tag_marker) { space.repeat(2) >> str('-') >> space }
    rule(:tag)        { tag_id >> tag_marker }
    rule(:free_text)  { match['^[\n\r]'].repeat(0) }
    rule(:content)    { tag.absent? >> free_text >> line }

    rule(:contents)   { content.repeat(1).as(:contents) }
    rule(:titles)     { title | second_title | title_series | series_title }
    rule(:authors)    { author | secondary_author | editor }
    rule(:dates)      { primary_date | pub_year | secondary_date }
    rule(:periodical) { publisher | volume | issue | start_page | end_page | city | isbn | address}
    rule(:misc_tags)  { availability | pdf | misc_1 | misc_2 | misc_3 | related_records | images | series | user_definable1 | user_definable2 | user_definable3 | user_definable4 | user_definable5 }
    rule(:record)     { abstract | titles |  authors | dates | note | periodical | doi |
                        local_id  | kw | reprint_status | url | full_text |
                        misc_tags | journal | language | an | da | et | lb | rn }

    rule(:stanza)     { start_tag.as(:type) >> (record | line).repeat >> end_tag }
    rule(:root)       { import | stanza.as(:stanza).repeat }

    rule(:path_chars) { (str('/').maybe >> match('[a-zA-Z0-9\-\._~]')).repeat }
    rule(:import)     { str('@import') >> space >> path_chars.as(:file_name) }
  end
end
