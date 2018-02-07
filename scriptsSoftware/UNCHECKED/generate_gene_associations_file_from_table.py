#!/usr/bin/env python
__author__    = "Alexander Kanitz"
__copyright__ = "Copyright 2016, Biozentrum, University of Basel"
__license__   = "MIT"
__version__   = "1.0"
__email__     = "alexander.kanitz@alumni.ethz.ch"

'''Generates a gene associations format (GAF) 2.0 or 2.1 file from a table containing (at least) object identifiers, associated GO terms, domains and evidence codes. Refer to the following link for GAF specifications: "http://www.geneontology.org/page/go-annotation-file-formats".'''

# Import modules
import sys
import argparse
import re

# Set defaults
header_prefix = "!gaf-version: "
field_regex = re.compile('^\#\d+')
allowed_aspects = {'C': 'C', 'F': 'F', 'P': 'P', 'COMPONENT': 'C', 'FUNCTION': 'F', 'PROCESS': 'P', 'CELLULAR_COMPONENT': 'C', 'MOLECULAR_FUNCTION': 'F', 'BIOLOGICAL_PROCESS': 'P'}
allowed_codes = ['EXP', 'IDA', 'IPI', 'IMP', 'IGI', 'IEP', 'ISS', 'ISO', 'ISA', 'ISM', 'IGC', 'IBA', 'IBD', 'IKR', 'IRD', 'RCA', 'TAS', 'NAS', 'IC', 'ND', 'IEA']
allowed_qualifiers = ['NOT', 'contributes_to', 'colocalizes_with']

# Initialize parser object
parser = argparse.ArgumentParser(
    description='Generates a gene associations format (GAF) 2.0 or 2.1 file from a table containing (at least) object identifiers, associated GO terms, domains and evidence codes. Refer to the following link for GAF specifications: "http://www.geneontology.org/page/go-annotation-file-formats".',
    epilog='NOTE: Values for "--db", "--with-from", "--type" and "--assigned-by" are not validated!',
    usage='%(prog)s [--infile PATH] [--id FIELD] [--go FIELD] [--evidence FIELD] [--aspect FIELD] [OPTIONS]',
    add_help=False
)

# Add arguments
parser.add_argument(
    '--infile',
    action='store',
    default=None,
    help='Input filename. If not supplied, reads from STDIN.',
    metavar='PATH|STDIN',
)
parser.add_argument(
    '--id',
    action='store',
    default=1,
    type=int,
    help='Specifiy the field of the input file that contains the ("--db"-derived) identifiers for the GO-associated objects (e.g. genes), e.g. "1" for the first column.',
    metavar='FIELD'
)
parser.add_argument(
    '--go',
    action='store',
    default=2,
    type=int,
    help='Specifiy the field of the input file that contains the GO terms associated with the "--db"-derived objects, e.g. "2" for the second column.',
    metavar='FIELD'
)
parser.add_argument(
    '--evidence',
    action='store',
    default=3,
    type=int,
    help='Specifiy the field of the input file that contains the evidence code for a given object:GO term pair, e.g. "3" for the third column.',
    metavar='FIELD'
)
parser.add_argument(
    '--aspect',
    action='store',
    default=4,
    type=int,
    help='Specifiy the field of the input file that contains the domain/namespace/ontology of a given GO term in a object:GO pair. Must be one of "C", "F", "P", "component", "function", "process", "cellular component", "molecular function" or "biological process" (capitalization ignored, underscores allowed).',
    metavar='FIELD'
)
parser.add_argument(
    '--db',
    action='store',
    default='Ensembl',
    help='Database from which the object identifiers are derived. Must be included in this reference: "http://amigo.geneontology.org/xrefs". Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. If not supplied, the default value is used for all pairs.',
    metavar='DB|#FIELD'
)
parser.add_argument(
    '--symbol',
    action='store',
    default=None,
    type=int,
    help='Official symbol associated with the object identifier. Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, the values of "--id" are reused.',
    metavar='FIELD'
)
parser.add_argument(
    '--qualifier',
    action='store',
    default='',
    help='Flag modifying the interpretation of an annotation. If not empty, must be one or more of "NOT", "contributes_to", "colocalizes_with", separated by a pipe. Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. If not supplied, the field is left empty for all pairs.',
    metavar='QUALIFIER|#FIELD'
)
parser.add_argument(
    '--reference',
    action='store',
    default=None,
    type=int,
    help='One or more unique identifiers for a single source cited as an authority for the association of object and ontology term. Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, values for all pairs are derived from "--db" and "--id" like this: "<DB>:<ID>".',
    metavar='FIELD'
)
parser.add_argument(
    '--with-from',
    action='store',
    default=None,
    type=int,
    help='Additional identifier for annotations using certain evidence codes (IC, IEA, IGI, IPI, ISS). Must be one of "<DB>:<gene_symbol>", "<DB>:<gene_symbol[allele_symbol]>", "<DB>:<gene_id>", "<DB>:<protein_name>", "<DB>:<sequence_id>", "<GO>:<GO_id>", "<CHEBI>:<CHEBI_id>". Specifiy a field of the input file (e.g. "#3") that contains this information for each object:GO term pair. If not specified, the values in "--go" will be used for object:GO term pairs with evidence code "IC". In all other cases, the field will be left empty. Note that missing/wrong information in this field is a likely source of errors in downstream applications!',
    metavar='FIELD'
)
parser.add_argument(
    '--name',
    action='store',
    default=None,
    type=int,
    help='Official name/description associated with the object identifier. Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, the field is left empty for all pairs.',
    metavar='FIELD'
)
parser.add_argument(
    '--synonym',
    action='store',
    default=None,
    type=int,
    help='Synonym(s) for the object referenced by the object identifier. Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, the field is left empty for all pairs.',
    metavar='FIELD'
)
parser.add_argument(
    '--type',
    action='store',
    default='gene_product',
    help='Description of the type of gene product being annotated. Must be one of "protein_complex", "protein", "transcript", "ncRNA", "rRNA", "tRNA", "snRNA", "snoRNA", any subtype of ncRNA in the Sequence Ontology, or "gene_product" (if precise product type is unknown). Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. If not supplied, "gene_product" is used for all pairs.',
    metavar='TYPE|#FIELD'
)
parser.add_argument(
    '--taxon',
    action='store',
    default='taxon:9606',
    help='Taxon identifier of the form "taxon:<ID>". Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. By default, "taxon:9606" (Homo sapiens) is used for all pairs.',
    metavar='TAXON_ID|#FIELD'
)
parser.add_argument(
    '--date',
    action='store',
    default='20000101',
    help='Date on which annotation was made/recorded. Format YYYYMMDD. Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. If not supplied, "20000101" is used for every pair.',
    metavar='DATE|#FIELD'
)
parser.add_argument(
    '--assigned-by',
    dest='ass_by',
    action='store',
    default=None,
    help='Database that made/recorded the annotation. Specifiy a field of the input file (prefixed by an exclamation mark, e.g. "#3") that contains this information for each object:GO term pair *OR* a constant value used for all pairs. By default, the value/s of "--db" is/are reused.',
    metavar='DB|#FIELD'
)
parser.add_argument(
    '--annotation-extension',
    dest='anno_ext',
    action='store',
    default=None,
    type=int,
    help='Cross references to other ontologies that can be used to qualify or enhance the annotation. Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, the field is left empty for all pairs.',
    metavar='FIELD'
)
parser.add_argument(
    '--product-id',
    dest='prod_id',
    action='store',
    default=None,
    type=int,
    help='Allows the annotation of specific variants of the object (e.g. different gene products of a single gene). Specifiy a field of the input file (e.g. "5") that contains this information for each object:GO term pair. If not supplied, the field is left empty for all pairs.',
    metavar='FIELD'
)
parser.add_argument(
    '--gaf-version',
    action='store',
    default='2.0',
    choices=['2.0', '2.1'],
    help='Specify the GAF version to be generated. Must be one of "2.0" or "2.1".',
    metavar='VERSION'
)
parser.add_argument(
    '--has-header',
    action='store_true',
    help='Specify if the input file contains a header line.'
)
parser.add_argument(
    '--verbose',
    action='store_true',
    help='Write log messages.'
)
parser.add_argument(
    '--version',
    action='version',
    version='%(prog)s 1.0',
    help='Show version and exit.'
)
parser.add_argument(
    '--help',
    action='help',
    help='Show this help message and exit.'
)

# Parse arguments
args = parser.parse_args()

# Process arguments
if args.db        is not None and field_regex.match(args.db):
    args.db        = int(args.db[1:])
if args.qualifier is not None and field_regex.match(args.qualifier):
    args.qualifier = int(args.qualifier[1:])
if args.type      is not None and field_regex.match(args.type):
    args.type      = int(args.type[1:])
if args.taxon     is not None and field_regex.match(args.taxon):
    args.taxon     = int(args.taxon[1:])
if args.date      is not None and field_regex.match(args.date):
    args.date      = int(args.date[1:])
if args.ass_by    is not None and field_regex.match(args.ass_by):
    args.ass_by    = int(args.ass_by[1:])
   
# Get minimal number of required fields
ints = []
for arg in vars(args):
    val = getattr(args, arg)
    if isinstance(val, int) and not isinstance(val, bool):
        ints.append(val)
min_fields = max(ints)

# Build header
header = "{prefix}{version}\n".format(prefix=header_prefix, version=args.gaf_version)

# Open input file for reading
import sys
# parse command line
if args.infile is None:
    f = sys.stdin
else:
    f = open(args.infile)
    
# Write header
sys.stdout.write(header)

# Log status
if args.verbose:
    sys.stderr.write("Processing input file...\n")

# Iterate over input file
for line in f:

    # Skip header
    if args.has_header:
        args.has_header = False
        continue

    # Split line into fields
    fields = line.strip().split("\t")

    # Assert that line has enough fields
    if len(fields) < min_fields:
        sys.stderr.write("[ERROR] The following line does not have enough fields:\n{value}".format(value=line))
        sys.exit(1)

    # Set field values
    db        = fields[args.db        - 1] if isinstance(args.db,        int) else args.db
    id        = fields[args.id        - 1]
    symbol    = fields[args.symbol    - 1] if isinstance(args.symbol,    int) else id
    qualifier = fields[args.qualifier - 1] if isinstance(args.qualifier, int) else args.qualifier
    go        = fields[args.go        - 1]
    reference = fields[args.reference - 1] if isinstance(args.reference, int) else "{db}:{id}".format(db=db, id=id)
    evidence  = fields[args.evidence  - 1]
    with_from = fields[args.with_from - 1] if isinstance(args.with_from, int) else ""
    aspect    = fields[args.aspect    - 1]
    name      = fields[args.name      - 1] if isinstance(args.name,      int) else ""
    synonym   = fields[args.synonym   - 1] if isinstance(args.synonym,   int) else ""
    type      = fields[args.type      - 1] if isinstance(args.type,      int) else args.type
    taxon     = fields[args.taxon     - 1] if isinstance(args.taxon,     int) else args.taxon
    date      = fields[args.date      - 1] if isinstance(args.date,      int) else args.date
    ass_by    = fields[args.ass_by    - 1] if isinstance(args.ass_by,    int) else db
    anno_ext  = fields[args.anno_ext  - 1] if isinstance(args.anno_ext,  int) else ""
    prod_id   = fields[args.prod_id   - 1] if isinstance(args.prod_id,   int) else ""

    # Validate field values & handle exceptions
    if qualifier and not set(qualifier.split("|")).issubset(set(allowed_qualifiers)):
        sys.stderr.write("[WARNING] Illegal value in field 'qualifier': {value}\n".format(value=qualifier))
        continue
    aspect_proc = aspect.upper().replace(" ", "_")
    if aspect_proc in allowed_aspects:
        aspect = allowed_aspects[aspect_proc]
    else:
        sys.stderr.write("[WARNING] Illegal value in field 'aspect': {value}\n".format(value=aspect))
        continue
    if evidence == "IC":
        with_from = go
    elif evidence not in allowed_codes:
        sys.stderr.write("[WARNING] Illegal value in field 'evidence': {value}\n".format(value=evidence))
        continue
    if not symbol:
        symbol = id

    # Assemble output line
    line = "\t".join([db, id, symbol, qualifier, go, reference, evidence, with_from, aspect, name, synonym, type, taxon, date, ass_by, anno_ext, prod_id])

    # Write line
    sys.stdout.write(line + "\n")

# Log status
if args.verbose:
    sys.stderr.write("Done.\n")

# Return zero exit code
sys.exit(0)
