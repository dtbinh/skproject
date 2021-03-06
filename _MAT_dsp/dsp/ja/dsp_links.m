% DSP_LINKS   DSP System Toolbox ライブラリにリンクしているブロックの
%             ライブラリリンク情報の表示と出力
% 
%    dsp_links() は、3つの要素をもつ構造体を返します。各要素は、現在のシステムの
%    ライブラリブロックの名前を含む文字列のセル配列を含みます。ブロックは、3つの
%    カテゴリにグループ化されています: obsolete, deprecated, current
%
%    dsp_links(sys) は、gcs の代わりに、名前のついたシステムに対して上記のように
%    機能します。
%
%    古いブロック (Obsolete) はサポートされないブロックです。それらは正しく機能
%    しないかもしれません。
%
%    廃止予定のブロック (Deprecated) は、まだサポートされていますが、将来のリリース
%    で廃止されます。
%
%    現在のブロック (Current) は、サポートされており、最新のブロックの機能を実行します。
%
%    参考 LIBLINKS.


% Copyright 1995-2011 The MathWorks, Inc.
