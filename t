
::ng-deep .md-menu-item {
    height: auto !important;
    min-height: unset !important;
}


.md-label {
    display: block;
    white-space: normal;
    word-break: break-word;
}

.md-menu-item {
    display: block;
    white-space: normal;
    word-break: break-word;
    overflow-wrap: break-word;
    height: auto !important;      /* السماح بارتفاع ديناميكي */
    min-height: 48px;             /* احتفظ بحد أدنى إذا أردت */
    padding: 8px;                 /* مساحة داخلية مناسبة */
    box-sizing: border-box;
}


.md-menu-item {
    min-height: 48px; /* فقط كحد أدنى، وليس ارتفاع ثابت */
    height: auto !important;
}



.md-menu-item {
    height: auto !important;      /* السماح بارتفاع ديناميكي */
    min-height: unset !important; /* إزالة الحد الأدنى الثابت */
    white-space: normal;
    word-break: break-word;
    overflow-wrap: break-word;
    padding: 8px;                 /* مساحة داخلية مناسبة */
}
