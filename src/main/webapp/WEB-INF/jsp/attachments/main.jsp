<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>

<jsp:directive.include file="/WEB-INF/jsp/include.jsp"/>
<c:set var="n"><portlet:namespace/></c:set>
<c:if test="${!usePortalJsLibs}">
    <script src="<rs:resourceURL value='/rs/jquery/1.6.1/jquery-1.6.1.min.js'/>" type="text/javascript"></script>
</c:if>

<script src="<c:url value='/js/fineuploader/fineuploader-3.3.0.js'/>"></script>
<link rel="stylesheet" type="text/css" href="<c:url value='/js/fineuploader/fineuploader-3.3.0.css'/>" />
<link rel="stylesheet" type="text/css" href="<c:url value='/css/attachments.css'/>" />

<div id="${n}attachments">
    <div class="lb_backdrop"></div>
    <div class="lb_container">
        <div class="fl-widget portlet" role="section">
            <div class="fl-widget-titlebar portlet-title" role="sectionhead">
                <h2 role="heading">Attachments</h2>
            </div> <!-- end: portlet-title -->
            <div class="fl-widget-content portlet-body" role="main">
                <div class="portlet-section" role="region">
                    <div class="lb_body">
                        <label>Filename</label>(optional)<br/>
                        <input id="${n}filename" type="text"/>
                        <br/><br/>
                        <div id="${n}file-uploader"></div>
                    </div>
                </div>
                <div class="portlet-section" role="region">
                    <div class="lb_controls">
                    <input type="button" id="${n}triggerUpload" class="btn btn-primary" value="Upload"/>
                    <input type="button" id="${n}cancelUpload" class="btn btn-primary lb_close" value="Cancel"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    var ${n} = ${n} || {};

    <c:choose>
        <c:when test="${!usePortalJsLibs}">
            ${n}.jQuery = jQuery.noConflict(true);
        </c:when>
        <c:otherwise>
            <c:set var="ns"><c:if test="${ not empty portalJsNamespace }">${ portalJsNamespace }.</c:if></c:set>
            ${n}.jQuery = ${ ns }jQuery;
        </c:otherwise>
    </c:choose>

    ${n}.jQuery(function () {
        var $ = ${n}.jQuery;

        $("#${n}attachments .lightbox").click(function () {
            ${n}open_box();
        });
    });

    function ${n}open_box()
    {
        var $ = ${n}.jQuery;
        $("#${n}attachments .lb_backdrop, #${n}attachments .lb_container").animate({'opacity': '.50'}, 300, 'linear');
        $("#${n}attachments .lb_container").animate({'opacity': '1.00'}, 300, 'linear');
        $("#${n}attachments .lb_backdrop, #${n}attachments .lb_container").css('display', 'block');
    }

    function ${n}close_box()
    {
        var $ = ${n}.jQuery;
        $("#${n}attachments .lb_backdrop, #${n}attachments .lb_container").animate({'opacity':'0'}, 300, 'linear', function(){
            $("#${n}attachments .lb_backdrop, #${n}attachments .lb_container").css('display', 'none');
        });
    }

    var upAttachments = {
        hide: function() {
            var $ = ${n}.jQuery;
            $("#${n}filename").val('');
            ${n}close_box();
        },
        show: function(callback) {
            var $ = ${n}.jQuery;
            var uploader = new qq.FineUploader({
                element: $("#${n}file-uploader")[0],

                request: {
                    endpoint: "<c:url value='/api/upload.json'/>",
                    forceMultipart: true,
                    paramsInBody: true,
                    params: {
                        filename: function () { return $("#${n}filename").val(); }
                    }
                },

                multiple: false,

                validation: {
                    allowedExtensions: ['gif', 'txt'],
                    sizeLimit: 20971520,
                    stopOnFirstInvalidFile: true
                },

                autoUpload: false,

                text: {
                    uploadButton: "Select File",
                    cancelButton: 'Cancel',
                    retryButton: 'Retry',
                    failUpload: 'Upload failed',
                    dragZone: 'Drop files here to upload',
                    formatProgress: "{percent}% of {total_size}",
                    waitingForResponse: "Processing..."
                },

                messages: {
                    typeError: "{file} has an invalid extension. Valid extension(s): {extensions}.",
                    sizeError: "{file} is too large, maximum file size is {sizeLimit}.",
                    minSizeError: "{file} is too small, minimum file size is {minSizeLimit}.",
                    emptyError: "{file} is empty, please select files again without it.",
                    noFilesError: "No files to upload.",
                    onLeave: "The files are being uploaded, if you leave now the upload will be cancelled."
                },

                debug: true,

                callbacks: {
                    onSubmit: function (id, filename) {
                        var $ = ${n}.jQuery;
                        var tmp = document.getElementById("${n}filename").value;
                        filename = tmp ? tmp : filename;
                        var url = "<c:url value='/api/exists/"+filename+".json'/>";
                        var failed = false;
                        $.ajax({
                            url:     url,
                            async:   false,
                            success: function(result) {
                                if(result.exists == true)
                                {
                                    if(!confirm('This will overwrite an existing file. Continue?'))
                                    {
                                        failed = true;
                                    }
                                }
                            }
                        });
                        if(failed) return false;
                    },
                    onComplete: function (id, fileName, responseJSON) {
                        var $ = ${n}.jQuery;
                        callback(responseJSON);
                    },
                    showMessage: function (message) {
                        var $ = ${n}.jQuery;
                        $("#${n}file-uploader").append('<div class="alert alert-error">' + message + '</div>');
                    }
                }

            });

            $("#${n}attachments .lb_close, #${n}attachments .lb_backdrop").click(function () {
                var $ = ${n}.jQuery;
                uploader.reset();
                $("#${n}filename").val('');
                ${n}close_box();
            });

            $("#${n}triggerUpload").click(function () {
                uploader.uploadStoredFiles();
            })

            ${n}open_box();
        },
        info: function(attachmentId,callback) {
            var $ = ${n}.jQuery;
            var url = "<c:url value='/api/details/"+attachmentId+".json'/>";
            var request = $.ajax({
                url: url,
                type: "GET"
            });
            request.done(function(data) { callback(data); });
        },
        download: function(attachment) {
            var $ = ${n}.jQuery;
            var url = "<c:url value='/api/download/"+attachment+".json'/>";
            $('<form action="'+ url +'" method="GET"></form>').appendTo('body').submit().remove();
        }
    };
</script>