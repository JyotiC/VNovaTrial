@page
{
    /* Set landscape orientation */
    size:landscape;

    /* Set page margins */
    margin-top:0em;
    margin-bottom:2em;
    margin-left:0em;
    margin-right:0em;

    /* Set page numbers */
    @bottom-center
    {
        content: "Page " counter(page) " of " counter(pages);
    }
}

body
{
    font-family:Arial;
    font-size:10pt;
}

.pageTitle
{
    font-size:12pt;
    font-weight:bold;
}

.dataTable
{
    /* Display table header on each page */
    -fs-table-paginate:paginate;
}

.columnHeader
{
    font-weight:bold;
    vertical-align:bottom;
    border-bottom:1px solid #000000;
}

.rowLayout
{
    page-break-inside:avoid;
}

.columnLayout
{
    vertical-align:top;
}