<?xml version='1.0' encoding='utf-8'?> <!--E.g. msxsl ...xml Import.xslt Type=SpecimenGroup SubType=Rodent--> 
<xsl:stylesheet version='1.0' xmlns:xsl='http://www.w3.org/1999/XSL/Transform' xmlns:msxsl='urn:schemas-microsoft-com:xslt' extension-element-prefixes='msxsl' xmlns:utils='https://project-lifecycle.herokuapp.com/'><!--exclude-result-prefixes='msxsl'-->
  <!-- Turn off auto-insertion of <?xml> tag and set indenting on -->
  <xsl:output method='text' encoding='utf-8' indent='yes'/>
  <xsl:param name='Type' select='Type'/>
  <xsl:param name='SubType' select='SubType'/>
  <!--Debug Only-->
  <!--<xsl:variable name='Type' select='"SpecimenGroup"'/>
  <xsl:variable name='SubType' select='"Human"'/>-->
  <!--<xsl:variable name='Type' select='"Activity"'/>
  <xsl:variable name='SubType' select='"None"'/>-->
  <!--<xsl:variable name='Type' select='"Dataset"'/>
  <xsl:variable name='SubType' select='"None"'/>-->

  <msxsl:script implements-prefix='utils' language='javascript'>
    <![CDATA[

    function lookupSpecies(label) {
        switch (label.toLowerCase()) {
            case 'mus-musculus':
            case 'mus musculus':
                return 'obo:NCBITaxon_10090';
            case 'rattus-norvegicus':
            case 'rattus norvegicus':
                return 'obo:NCBITaxon_10116';
            case 'homo-sapiens':
            case 'homo sapiens':
                return 'obo:NCBITaxon_9606';
            default:
                return 'Unknown';
        }
    }

    function lookupSex(label) {
        switch (label.toLowerCase().substr(0,1)) {
            case 'm':
                return 'HBP_SEX:0000001';
            case 'f':
                return 'HBP_SEX:0000002';
            default:
                return 'Unknown';
        }
    }

    function lookupParcellationAtlas(label) {
        switch (label) {
            case 'Jülich Cytoarchitectonic Brain Atlas':
                return 'JBA';
            default:
                return label;
        }
    }

    function lookupAgeCategory(label) {
        switch (label.toLowerCase().substr(0,1)) {
            case 'n':
                return 'N';
            case 'i':
                return 'I';
            case 'j':
                return 'J';
            case 'a':
                return 'A';
            default:
                return 'Unknown';
        }
    }

    function lookupPreparation(label) {
        switch (label.toLowerCase()) {
            case 'in vivo':
                return 'InVivo';
            case 'ex vivo':
                return 'ExVivo';
            default:
                return 'Unknown';
        }
    }

    function lookupEmbargoStatus(label) {
        switch (label.toLowerCase()) {
            case 'no embargo':
                return 'Free';
            default:
                return label;
        }
    }

    function getArray(items) {
        var quotedItems='';
        var splitItems=items.split('|');
        for (var item in splitItems) {
            if (quotedItems.length)
                quotedItems+=',';
            quotedItems+='"'+splitItems[item]+'"';
        }
        return (new String(quotedItems)).toString();
    }

    function getName(item) {
        if (item.indexOf('|')==-1) {
            return item;
        }
        else {
            return item.split('|')[0];
        }
    }

    function getValue(item) {
        if (item.indexOf('|')==-1) {
            return ''; // Only has a name
        }
        else {
            return item.split('|')[1];
        }
    }

    function escapeCarriageReturn(item) {
        return item.replace(/\n\s*/g,'\\n');
    }

    function escapeBackslash(item) {
        return item.replace(/\\/g,'\\\\');
    }

    ]]>
  </msxsl:script>

  <!-- strip whitespace from whitespace-only nodes -->
  <xsl:strip-space elements='*'/>

  <xsl:template match='* | /'/>
  <xsl:template match='* | /' mode='Subject'/>
  <xsl:template match='* | /' mode='Sample'/>
  <xsl:template match='* | /' mode='Activity'/>
  <xsl:template match='* | /' mode='Dataset'/>

  <xsl:template match='text() | @*'/>

  <!-- start with the root element -->

  <xsl:template match='/'>
    <xsl:text>{"Specification": </xsl:text>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": </xsl:text>
    <xsl:text>"</xsl:text><xsl:value-of select='$Type' /><xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:choose>
      <xsl:when test='$Type="SpecimenGroup"'>
        <xsl:text>"</xsl:text><xsl:value-of select='item/children/item[name="SubjectID"]/value' /><xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:when test='$Type="Activity"'>
        <xsl:text>"</xsl:text><xsl:value-of select='item/children/item[name="ActivityID"]/value' /><xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:when test='$Type="Dataset"'>
        <xsl:text>"</xsl:text><xsl:value-of select='item/children/item[name="DatasetID"]/value' /><xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>null</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>, </xsl:text>
    <xsl:text>"children": </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:choose>
      <xsl:when test='$Type="SpecimenGroup"'>
        <xsl:call-template name='SpecimenGroup'/>
      </xsl:when>
      <xsl:when test='$Type="Activity"'>
        <xsl:call-template name='Activity'/>
      </xsl:when>
      <xsl:when test='$Type="Dataset"'>
        <xsl:call-template name='Dataset'/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>]</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:if test='position() &lt; last()'>,</xsl:if>
  </xsl:template>

  <xsl:template name='SpecimenGroup'>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": "Subjects"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:text>"</xsl:text><xsl:value-of select='$SubType' /><xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"children": </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select='item'/>
    <xsl:text>]</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template name='Activity'>
    <xsl:apply-templates select='item'/>
  </xsl:template>

  <xsl:template name='Dataset'>
    <xsl:apply-templates select='item'/>
  </xsl:template>

  <!-- top-level item -->
  <xsl:template match='item[not(parent::children)]'>
    <xsl:choose>
      <xsl:when test='$Type="SpecimenGroup"'>
        <xsl:text>{</xsl:text>
        <xsl:text>"name": </xsl:text>
        <xsl:text>"Subject"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"value": </xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:value-of select='children/item[name="SubjectID"]/value' />
        <xsl:text>"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"children": </xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select='children/item' mode='Subject'/>
        <xsl:choose>
          <xsl:when test='starts-with(children/item/name, "SubjectID")'>
            <xsl:text>, </xsl:text>
          </xsl:when>
          <xsl:when test='starts-with(children/item/name, "SampleID")'>
          </xsl:when>
          <xsl:otherwise>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>{</xsl:text>
        <xsl:text>"name": "Samples"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"value": </xsl:text>
        <xsl:text>"</xsl:text><xsl:value-of select='$SubType' /><xsl:text>"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"children": </xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:text>{</xsl:text>
        <xsl:text>"name": </xsl:text>
        <xsl:text>"Sample"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"value": </xsl:text>
        <xsl:text>"</xsl:text>
        <xsl:value-of select='children/item[name="SampleID"]/value' />
        <xsl:text>"</xsl:text>
        <xsl:text>, </xsl:text>
        <xsl:text>"children": </xsl:text>
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select='children/item' mode='Sample'/>
        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:when test='$Type="Activity"'>
        <xsl:apply-templates select='children/item' mode='Activity'/>
      </xsl:when>
      <xsl:when test='$Type="Dataset"'>
        <xsl:apply-templates select='children/item' mode='Dataset'/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--SpecimenGroup-->
  
  <!--Subject.All-->
  
  <xsl:template match='item[./name="Species"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(utils:lookupSpecies(string(./value)))'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Sex"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(utils:lookupSex(string(./value)))'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Age"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="AgeCategory"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(utils:lookupAgeCategory(string(./value)))'/>
    </xsl:call-template>
  </xsl:template>

  <!--Subject.Rodent-->
  
  <xsl:template match='item[./name="Strain"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Genotype"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Weight"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <!--Subject.Human-->
  
  <xsl:template match='item[./name="CauseOfDeath"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="DoB"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="DoD"]' mode='Subject'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <!--Sample.All-->

  <xsl:template match='item[./name="ParcellationAtlas"]' mode='Sample'>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": "ParcellationAtlas"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='string(utils:lookupParcellationAtlas(string(./value)))' />
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"children": </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select='../item[./name="Region"]' mode='ParcellationAtlas'/>
    <xsl:text>]</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test='(following-sibling::*)'>
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='item[./name="Region"]' mode='ParcellationAtlas'>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='./name' />
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='string(utils:getName(string(./value)))' />
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='string(utils:getValue(string(./value)))' />
    <xsl:text>"</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:text>]</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!--Sample.Rodent-->

  <xsl:template match='item[./name="Method"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Files"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <!--Sample.Human-->
  
  <xsl:template match='item[./name="WeightPreFix"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="WeightPostFix"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Fixation"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Embedding"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Staining"]' mode='Sample'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <!--Activity-->
  
  <xsl:template match='item[./name="EthicsAuthority"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="EthicsApprovalID"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Method"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Protocol"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Preparation"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(utils:lookupPreparation(string(./value)))'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Description"]' mode='Activity'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(./value)'/><!--string(utils:escapeBackslash(string(./value)))-->
    </xsl:call-template>
  </xsl:template>

  <!--Dataset-->
  
  <xsl:template match='item[./name="DatasetID"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="SpecimenGroup"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Activity"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="LicenseType"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="LicenseID"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="ReleaseDate"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="EmbargoStatus"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(utils:lookupEmbargoStatus(string(./value)))'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Format"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="ReferenceSpace"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="ParcellationAtlas"]' mode='Dataset'>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": "ParcellationAtlas"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='string(utils:lookupParcellationAtlas(string(./value)))' />
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"children": </xsl:text>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select='../item[./name="Region"]' mode='ParcellationAtlas'/>
    <xsl:text>]</xsl:text>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test='(following-sibling::*)'>
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match='item[./name="Owner"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Contributor"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="DataLink"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Files"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="DatasetDOI"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="PublicationDOI"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='./value'/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match='item[./name="Description"]' mode='Dataset'>
    <xsl:call-template name='formatItem'>
      <xsl:with-param name='name' select='./name'/>
      <xsl:with-param name='value' select='string(./value)'/><!--string(utils:escapeBackslash(string(./value)))-->
    </xsl:call-template>
  </xsl:template>

  <!--Utils-->

  <xsl:template name='formatItem'>
    <xsl:param name='name'/>
    <xsl:param name='value'/>
    <xsl:text>{</xsl:text>
    <xsl:text>"name": </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:value-of select='$name' />
    <xsl:text>"</xsl:text>
    <xsl:text>, </xsl:text>
    <xsl:text>"value": </xsl:text>
    <xsl:choose>
      <xsl:when test='contains($value,"|")'>
        <xsl:text>[</xsl:text>
        <xsl:value-of select='string(utils:getArray(string($value)))' />
        <xsl:text>]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"</xsl:text>
        <xsl:value-of select='$value' />
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test='(following-sibling::*)'>
        <xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
