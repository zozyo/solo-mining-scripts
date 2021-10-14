#!/bin/bash

function phala_help()
{
cat << EOF
Usage:
	phala [OPTION]...

Options:
	help					展示帮助信息
	install					安装Phala挖矿套件
		<dcap>				安装DCAP驱动
		<isgx>				安装isgx驱动
	uninstall				卸载phala脚本
	start					启动挖矿(debug参数允许输出挖矿套件日志信息)
		<khala>				启动khala-node
	stop					停止挖矿程序
		<all>					停止所有容器
		<node>				停止phala-node容器
		<pruntime>			停止phala-pruntime容器
		<pherry>			停止phala-pherry容器
	config					配置
		<show>				查看配置信息（直接看到配置文件所有信息）
		<set>				重新配置
	status					查看挖矿套件运行状态
	update					不清理容器数据，更新容器
		<clean>				清理容器数据，更新容器
		<script>			更新脚本
	logs					打印所有容器日志信息
		<node>				打印phala-node容器日志
		<pruntime>			打印phala-pruntime容器日志
		<pherry>			打印phala-pherry容器日志
	sgx-test				运行挖矿测试程序
EOF
exit 0
}
