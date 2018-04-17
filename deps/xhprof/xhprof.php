<?php
define("XH_LOG_PATH", "/tmp/xhprof.log");
$xh_force_disable = false; //设置性能分析是否启用，设置为true表示关闭。
$max_time = 100; //millisecond

$xh_enable = false;
$start_time = microtime(true);

//这里可以设置需要进行性能分析的url和设置的超时时间。如果指定的url，响应时间超过了设置的超时时间，性能分析数据就会被记录下来。超时时间的单位为毫秒。
$xh_conf["urls"] = array(
    //url => max_time
    "/i/content/getdetail.json" => 100,
);

function xh_save_data()
{
    global $start_time, $xh_force_disable, $xh_enable, $max_time;
    $end_time = microtime(true);
    $cost_time = $end_time - $start_time;
    $cost_time *= 1000;
    if ($cost_time > $max_time && !$xh_force_disable && $xh_enable) {
        include_once "/www/sites/xhprof/xhprof_lib/utils/xhprof_lib.php";
        include_once "/www/sites/xhprof/xhprof_lib/utils/xhprof_runs.php";
        $xhprof_data = xhprof_disable();
        $objXhprofRun = new XHProfRuns_Default();
        $run_id = $objXhprofRun->save_run($xhprof_data, "xhprof");
        $log_data = "cost_time||$cost_time||run_id||$run_id||request_uri||" . $_SERVER["REQUEST_URI"] . "\n";
        //高并发下 可能会出现错乱情况。建议把 const_time run_id request_uri 写入到数据库
        file_put_contents(XH_LOG_PATH, $log_data, FILE_APPEND);
    }
}

$xh_request_uri = isset($_SERVER["REQUEST_URI"]) ? $_SERVER["REQUEST_URI"] : "";
$arr_xh_cur_url = explode("?", $xh_request_uri);
$xh_cur_url = $arr_xh_cur_url[0];

if (!$xh_force_disable && isset($xh_conf["urls"][$xh_cur_url])) {
    $xh_enable = true;
    $max_time = $xh_conf["urls"][$xh_cur_url];
    xhprof_enable(XHPROF_FLAGS_CPU + XHPROF_FLAGS_MEMORY);
    register_shutdown_function("xh_save_data");
} else {
    $xh_enable = false;
}
