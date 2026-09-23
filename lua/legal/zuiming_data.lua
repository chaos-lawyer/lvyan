-- zuiming_data.lua
-- 刑法罪名全部罪名及章节名称数据（包含全拼与小鹤双拼首拼索引）
-- 由工具脚本自动生成，严禁手动修改

local M = {}

M.records = {
  { text = "危害国家安全罪", comment = "〔第一章〕", type = "chapter", m_qp = "whgjaqz", m_fly = "whgjaqz", qp = { "whgjaqz", "whgjaq" }, fly = { "whgjaqz", "whgjaq" } },
  { text = "第一章 危害国家安全罪", comment = "〔第一章〕", type = "chapter_full", m_qp = "dyzwhgjaqz", m_fly = "dyvwhgjaqz", qp = { "dyzwhgjaqz", "whgjaqz" }, fly = { "dyvwhgjaqz", "whgjaqz" } },
  { text = "危害公共安全罪", comment = "〔第二章〕", type = "chapter", m_qp = "whggaqz", m_fly = "whggaqz", qp = { "whggaqz", "whggaq" }, fly = { "whggaqz", "whggaq" } },
  { text = "第二章 危害公共安全罪", comment = "〔第二章〕", type = "chapter_full", m_qp = "dezwhggaqz", m_fly = "devwhggaqz", qp = { "dezwhggaqz", "whggaqz" }, fly = { "devwhggaqz", "whggaqz" } },
  { text = "破坏社会主义市场经济秩序罪", comment = "〔第三章〕", type = "chapter", m_qp = "phshzyscjjzxz", m_fly = "phuhvyuijjvxz", qp = { "phshzyscjjzxz", "phshzyscjjzx" }, fly = { "phuhvyuijjvxz", "phuhvyuijjvx" } },
  { text = "第三章 破坏社会主义市场经济秩序罪", comment = "〔第三章〕", type = "chapter_full", m_qp = "dszphshzyscjjzxz", m_fly = "dsvphuhvyuijjvxz", qp = { "dszphshzyscjjzxz", "phshzyscjjzxz" }, fly = { "dsvphuhvyuijjvxz", "phuhvyuijjvxz" } },
  { text = "侵犯公民人身权利、民主权利罪", comment = "〔第四章〕", type = "chapter", m_qp = "qfgmrsqlmzqlz", m_fly = "qfgmruqlmvqlz", qp = { "qfgmrsqlmzqlz", "qfgmrsqlmzql" }, fly = { "qfgmruqlmvqlz", "qfgmruqlmvql" } },
  { text = "第四章 侵犯公民人身权利、民主权利罪", comment = "〔第四章〕", type = "chapter_full", m_qp = "dszqfgmrsqlmzqlz", m_fly = "dsvqfgmruqlmvqlz", qp = { "dszqfgmrsqlmzqlz", "qfgmrsqlmzqlz" }, fly = { "dsvqfgmruqlmvqlz", "qfgmruqlmvqlz" } },
  { text = "侵犯财产罪", comment = "〔第五章〕", type = "chapter", m_qp = "qfccz", m_fly = "qfciz", qp = { "qfccz", "qfcc" }, fly = { "qfciz", "qfci" } },
  { text = "第五章 侵犯财产罪", comment = "〔第五章〕", type = "chapter_full", m_qp = "dwzqfccz", m_fly = "dwvqfciz", qp = { "dwzqfccz", "qfccz" }, fly = { "dwvqfciz", "qfciz" } },
  { text = "妨害社会管理秩序罪", comment = "〔第六章〕", type = "chapter", m_qp = "fhshglzxz", m_fly = "fhuhglvxz", qp = { "fhshglzxz", "fhshglzx" }, fly = { "fhuhglvxz", "fhuhglvx" } },
  { text = "第六章 妨害社会管理秩序罪", comment = "〔第六章〕", type = "chapter_full", m_qp = "dlzfhshglzxz", m_fly = "dlvfhuhglvxz", qp = { "dlzfhshglzxz", "fhshglzxz" }, fly = { "dlvfhuhglvxz", "fhuhglvxz" } },
  { text = "危害国防利益罪", comment = "〔第七章〕", type = "chapter", m_qp = "whgflyz", m_fly = "whgflyz", qp = { "whgflyz", "whgfly" }, fly = { "whgflyz", "whgfly" } },
  { text = "第七章 危害国防利益罪", comment = "〔第七章〕", type = "chapter_full", m_qp = "dqzwhgflyz", m_fly = "dqvwhgflyz", qp = { "dqzwhgflyz", "whgflyz" }, fly = { "dqvwhgflyz", "whgflyz" } },
  { text = "贪污贿赂罪", comment = "〔第八章〕", type = "chapter", m_qp = "twhlz", m_fly = "twhlz", qp = { "twhlz", "twhl" }, fly = { "twhlz", "twhl" } },
  { text = "第八章 贪污贿赂罪", comment = "〔第八章〕", type = "chapter_full", m_qp = "dbztwhlz", m_fly = "dbvtwhlz", qp = { "dbztwhlz", "twhlz" }, fly = { "dbvtwhlz", "twhlz" } },
  { text = "渎职罪", comment = "〔第九章〕", type = "chapter", m_qp = "dzz", m_fly = "dvz", qp = { "dzz", "dz" }, fly = { "dvz", "dv" } },
  { text = "第九章 渎职罪", comment = "〔第九章〕", type = "chapter_full", m_qp = "djzdzz", m_fly = "djvdvz", qp = { "djzdzz", "dzz" }, fly = { "djvdvz", "dvz" } },
  { text = "军人违反职责罪", comment = "〔第十章〕", type = "chapter", m_qp = "jrwfzzz", m_fly = "jrwfvzz", qp = { "jrwfzzz", "jrwfzz" }, fly = { "jrwfvzz", "jrwfvz" } },
  { text = "第十章 军人违反职责罪", comment = "〔第十章〕", type = "chapter_full", m_qp = "dszjrwfzzz", m_fly = "duvjrwfvzz", qp = { "dszjrwfzzz", "jrwfzzz" }, fly = { "duvjrwfvzz", "jrwfvzz" } },
  { text = "生产、销售伪劣商品罪", comment = "〔第三章第一节〕", type = "section", m_qp = "scxswlspz", m_fly = "uixuwlupz", qp = { "scxswlspz", "scxswlsp" }, fly = { "uixuwlupz", "uixuwlup" } },
  { text = "第三章第一节 生产、销售伪劣商品罪", comment = "〔第三章第一节〕", type = "section_full", m_qp = "dszdyjscxswlspz", m_fly = "dsvdyjuixuwlupz", qp = { "dszdyjscxswlspz", "scxswlspz" }, fly = { "dsvdyjuixuwlupz", "uixuwlupz" } },
  { text = "走私罪", comment = "〔第三章第二节〕", type = "section", m_qp = "zsz", m_fly = "zsz", qp = { "zsz", "zs" }, fly = { "zsz", "zs" } },
  { text = "第三章第二节 走私罪", comment = "〔第三章第二节〕", type = "section_full", m_qp = "dszdejzsz", m_fly = "dsvdejzsz", qp = { "dszdejzsz", "zsz" }, fly = { "dsvdejzsz", "zsz" } },
  { text = "妨害对公司、企业的管理秩序罪", comment = "〔第三章第三节〕", type = "section", m_qp = "fhdgsqydglzxz", m_fly = "fhdgsqydglvxz", qp = { "fhdgsqydglzxz", "fhdgsqydglzx" }, fly = { "fhdgsqydglvxz", "fhdgsqydglvx" } },
  { text = "第三章第三节 妨害对公司、企业的管理秩序罪", comment = "〔第三章第三节〕", type = "section_full", m_qp = "dszdsjfhdgsqydglzxz", m_fly = "dsvdsjfhdgsqydglvxz", qp = { "dszdsjfhdgsqydglzxz", "fhdgsqydglzxz" }, fly = { "dsvdsjfhdgsqydglvxz", "fhdgsqydglvxz" } },
  { text = "破坏金融管理秩序罪", comment = "〔第三章第四节〕", type = "section", m_qp = "phjrglzxz", m_fly = "phjrglvxz", qp = { "phjrglzxz", "phjrglzx" }, fly = { "phjrglvxz", "phjrglvx" } },
  { text = "第三章第四节 破坏金融管理秩序罪", comment = "〔第三章第四节〕", type = "section_full", m_qp = "dszdsjphjrglzxz", m_fly = "dsvdsjphjrglvxz", qp = { "dszdsjphjrglzxz", "phjrglzxz" }, fly = { "dsvdsjphjrglvxz", "phjrglvxz" } },
  { text = "金融诈骗罪", comment = "〔第三章第五节〕", type = "section", m_qp = "jrzpz", m_fly = "jrvpz", qp = { "jrzpz", "jrzp" }, fly = { "jrvpz", "jrvp" } },
  { text = "第三章第五节 金融诈骗罪", comment = "〔第三章第五节〕", type = "section_full", m_qp = "dszdwjjrzpz", m_fly = "dsvdwjjrvpz", qp = { "dszdwjjrzpz", "jrzpz" }, fly = { "dsvdwjjrvpz", "jrvpz" } },
  { text = "危害税收征管罪", comment = "〔第三章第六节〕", type = "section", m_qp = "whsszgz", m_fly = "whuuvgz", qp = { "whsszgz", "whsszg" }, fly = { "whuuvgz", "whuuvg" } },
  { text = "第三章第六节 危害税收征管罪", comment = "〔第三章第六节〕", type = "section_full", m_qp = "dszdljwhsszgz", m_fly = "dsvdljwhuuvgz", qp = { "dszdljwhsszgz", "whsszgz" }, fly = { "dsvdljwhuuvgz", "whuuvgz" } },
  { text = "侵犯知识产权罪", comment = "〔第三章第七节〕", type = "section", m_qp = "qfzscqz", m_fly = "qfvuiqz", qp = { "qfzscqz", "qfzscq" }, fly = { "qfvuiqz", "qfvuiq" } },
  { text = "第三章第七节 侵犯知识产权罪", comment = "〔第三章第七节〕", type = "section_full", m_qp = "dszdqjqfzscqz", m_fly = "dsvdqjqfvuiqz", qp = { "dszdqjqfzscqz", "qfzscqz" }, fly = { "dsvdqjqfvuiqz", "qfvuiqz" } },
  { text = "扰乱市场秩序罪", comment = "〔第三章第八节〕", type = "section", m_qp = "rlsczxz", m_fly = "rluivxz", qp = { "rlsczxz", "rlsczx" }, fly = { "rluivxz", "rluivx" } },
  { text = "第三章第八节 扰乱市场秩序罪", comment = "〔第三章第八节〕", type = "section_full", m_qp = "dszdbjrlsczxz", m_fly = "dsvdbjrluivxz", qp = { "dszdbjrlsczxz", "rlsczxz" }, fly = { "dsvdbjrluivxz", "rluivxz" } },
  { text = "扰乱公共秩序罪", comment = "〔第六章第一节〕", type = "section", m_qp = "rlggzxz", m_fly = "rlggvxz", qp = { "rlggzxz", "rlggzx" }, fly = { "rlggvxz", "rlggvx" } },
  { text = "第六章第一节 扰乱公共秩序罪", comment = "〔第六章第一节〕", type = "section_full", m_qp = "dlzdyjrlggzxz", m_fly = "dlvdyjrlggvxz", qp = { "dlzdyjrlggzxz", "rlggzxz" }, fly = { "dlvdyjrlggvxz", "rlggvxz" } },
  { text = "妨害司法罪", comment = "〔第六章第二节〕", type = "section", m_qp = "fhsfz", m_fly = "fhsfz", qp = { "fhsfz", "fhsf" }, fly = { "fhsfz", "fhsf" } },
  { text = "第六章第二节 妨害司法罪", comment = "〔第六章第二节〕", type = "section_full", m_qp = "dlzdejfhsfz", m_fly = "dlvdejfhsfz", qp = { "dlzdejfhsfz", "fhsfz" }, fly = { "dlvdejfhsfz", "fhsfz" } },
  { text = "妨害国（边）境管理罪", comment = "〔第六章第三节〕", type = "section", m_qp = "fhgbjglz", m_fly = "fhgbjglz", qp = { "fhgbjglz", "fhgbjgl" }, fly = { "fhgbjglz", "fhgbjgl" } },
  { text = "第六章第三节 妨害国（边）境管理罪", comment = "〔第六章第三节〕", type = "section_full", m_qp = "dlzdsjfhgbjglz", m_fly = "dlvdsjfhgbjglz", qp = { "dlzdsjfhgbjglz", "fhgbjglz" }, fly = { "dlvdsjfhgbjglz", "fhgbjglz" } },
  { text = "妨害文物管理罪", comment = "〔第六章第四节〕", type = "section", m_qp = "fhwwglz", m_fly = "fhwwglz", qp = { "fhwwglz", "fhwwgl" }, fly = { "fhwwglz", "fhwwgl" } },
  { text = "第六章第四节 妨害文物管理罪", comment = "〔第六章第四节〕", type = "section_full", m_qp = "dlzdsjfhwwglz", m_fly = "dlvdsjfhwwglz", qp = { "dlzdsjfhwwglz", "fhwwglz" }, fly = { "dlvdsjfhwwglz", "fhwwglz" } },
  { text = "危害公共卫生罪", comment = "〔第六章第五节〕", type = "section", m_qp = "whggwsz", m_fly = "whggwuz", qp = { "whggwsz", "whggws" }, fly = { "whggwuz", "whggwu" } },
  { text = "第六章第五节 危害公共卫生罪", comment = "〔第六章第五节〕", type = "section_full", m_qp = "dlzdwjwhggwsz", m_fly = "dlvdwjwhggwuz", qp = { "dlzdwjwhggwsz", "whggwsz" }, fly = { "dlvdwjwhggwuz", "whggwuz" } },
  { text = "破坏环境资源保护罪", comment = "〔第六章第六节〕", type = "section", m_qp = "phhjzybhz", m_fly = "phhjzybhz", qp = { "phhjzybhz", "phhjzybh" }, fly = { "phhjzybhz", "phhjzybh" } },
  { text = "第六章第六节 破坏环境资源保护罪", comment = "〔第六章第六节〕", type = "section_full", m_qp = "dlzdljphhjzybhz", m_fly = "dlvdljphhjzybhz", qp = { "dlzdljphhjzybhz", "phhjzybhz" }, fly = { "dlvdljphhjzybhz", "phhjzybhz" } },
  { text = "走私、贩卖、运输、制造毒品罪", comment = "〔第六章第七节 第347条〕", type = "crime", m_qp = "zsfmyszzdpz", m_fly = "zsfmyuvzdpz", qp = { "zsfmyszzdpz", "zsfmyszzdp" }, fly = { "zsfmyuvzdpz", "zsfmyuvzdp" } },
  { text = "第六章第七节 走私、贩卖、运输、制造毒品罪", comment = "〔第六章第七节〕", type = "section_full", m_qp = "dlzdqjzsfmyszzdpz", m_fly = "dlvdqjzsfmyuvzdpz", qp = { "dlzdqjzsfmyszzdpz", "zsfmyszzdpz" }, fly = { "dlvdqjzsfmyuvzdpz", "zsfmyuvzdpz" } },
  { text = "组织、强迫、引诱、容留、介绍卖淫罪", comment = "〔第六章第八节〕", type = "section", m_qp = "zzqpyyrljsmyz", m_fly = "zvqpyyrljumyz", qp = { "zzqpyyrljsmyz", "zzqpyyrljsmy" }, fly = { "zvqpyyrljumyz", "zvqpyyrljumy" } },
  { text = "第六章第八节 组织、强迫、引诱、容留、介绍卖淫罪", comment = "〔第六章第八节〕", type = "section_full", m_qp = "dlzdbjzzqpyyrljsmyz", m_fly = "dlvdbjzvqpyyrljumyz", qp = { "dlzdbjzzqpyyrljsmyz", "zzqpyyrljsmyz" }, fly = { "dlvdbjzvqpyyrljumyz", "zvqpyyrljumyz" } },
  { text = "制作、贩卖、传播淫秽物品罪", comment = "〔第六章第九节〕", type = "section", m_qp = "zzfmcbyhwpz", m_fly = "vzfmibyhwpz", qp = { "zzfmcbyhwpz", "zzfmcbyhwp" }, fly = { "vzfmibyhwpz", "vzfmibyhwp" } },
  { text = "第六章第九节 制作、贩卖、传播淫秽物品罪", comment = "〔第六章第九节〕", type = "section_full", m_qp = "dlzdjjzzfmcbyhwpz", m_fly = "dlvdjjvzfmibyhwpz", qp = { "dlzdjjzzfmcbyhwpz", "zzfmcbyhwpz" }, fly = { "dlvdjjvzfmibyhwpz", "vzfmibyhwpz" } },
  { text = "背叛国家罪", comment = "〔第一章 第102条〕", type = "crime", m_qp = "bpgjz", m_fly = "bpgjz", qp = { "bpgjz", "bpgj" }, fly = { "bpgjz", "bpgj" } },
  { text = "分裂国家罪", comment = "〔第一章 第103条〕", type = "crime", m_qp = "flgjz", m_fly = "flgjz", qp = { "flgjz", "flgj" }, fly = { "flgjz", "flgj" } },
  { text = "煽动分裂国家罪", comment = "〔第一章 第103条〕", type = "crime", m_qp = "sdflgjz", m_fly = "udflgjz", qp = { "sdflgjz", "sdflgj" }, fly = { "udflgjz", "udflgj" } },
  { text = "武装叛乱、暴乱罪", comment = "〔第一章 第104条〕", type = "crime", m_qp = "wzplblz", m_fly = "wvplblz", qp = { "wzplblz", "wzplbl", "wzpl", "bl" }, fly = { "wvplblz", "wvplbl", "wvpl", "bl" } },
  { text = "颠覆国家政权罪", comment = "〔第一章 第105条〕", type = "crime", m_qp = "dfgjzqz", m_fly = "dfgjvqz", qp = { "dfgjzqz", "dfgjzq" }, fly = { "dfgjvqz", "dfgjvq" } },
  { text = "煽动颠覆国家政权罪", comment = "〔第一章 第105条〕", type = "crime", m_qp = "sddfgjzqz", m_fly = "uddfgjvqz", qp = { "sddfgjzqz", "sddfgjzq" }, fly = { "uddfgjvqz", "uddfgjvq" } },
  { text = "资助危害国家安全犯罪活动罪", comment = "〔第一章 第107条〕", type = "crime", m_qp = "zzwhgjaqfzhdz", m_fly = "zvwhgjaqfzhdz", qp = { "zzwhgjaqfzhdz", "zzwhgjaqfzhd" }, fly = { "zvwhgjaqfzhdz", "zvwhgjaqfzhd" } },
  { text = "投敌叛变罪", comment = "〔第一章 第108条〕", type = "crime", m_qp = "tdpbz", m_fly = "tdpbz", qp = { "tdpbz", "tdpb" }, fly = { "tdpbz", "tdpb" } },
  { text = "叛逃罪", comment = "〔第一章 第109条〕", type = "crime", m_qp = "ptz", m_fly = "ptz", qp = { "ptz", "pt" }, fly = { "ptz", "pt" } },
  { text = "间谍罪", comment = "〔第一章 第110条〕", type = "crime", m_qp = "jdz", m_fly = "jdz", qp = { "jdz", "jd" }, fly = { "jdz", "jd" } },
  { text = "为境外窃取、刺探、收买、非法提供国家秘密、情报罪", comment = "〔第一章 第111条〕", type = "crime", m_qp = "wjwqqctsmfftggjmmqbz", m_fly = "wjwqqctumfftggjmmqbz", qp = { "wjwqqctsmfftggjmmqbz", "wjwqqctsmfftggjmmqb", "wjwqq", "ct", "sm", "fftggjmm", "qb" }, fly = { "wjwqqctumfftggjmmqbz", "wjwqqctumfftggjmmqb", "wjwqq", "ct", "um", "fftggjmm", "qb" } },
  { text = "资敌罪", comment = "〔第一章 第112条〕", type = "crime", m_qp = "zdz", m_fly = "zdz", qp = { "zdz", "zd" }, fly = { "zdz", "zd" } },
  { text = "放火罪", comment = "〔第二章 第114条、第115条〕", type = "crime", m_qp = "fhz", m_fly = "fhz", qp = { "fhz", "fh" }, fly = { "fhz", "fh" } },
  { text = "决水罪", comment = "〔第二章 第114条、第115条〕", type = "crime", m_qp = "jsz", m_fly = "juz", qp = { "jsz", "js" }, fly = { "juz", "ju" } },
  { text = "爆炸罪", comment = "〔第二章 第114条、第115条〕", type = "crime", m_qp = "bzz", m_fly = "bvz", qp = { "bzz", "bz" }, fly = { "bvz", "bv" } },
  { text = "投放危险物质罪", comment = "〔第二章 第114条、第115条〕", type = "crime", m_qp = "tfwxwzz", m_fly = "tfwxwvz", qp = { "tfwxwzz", "tfwxwz" }, fly = { "tfwxwvz", "tfwxwv" } },
  { text = "以危险方法危害公共安全罪", comment = "〔第二章 第114条、第115条〕", type = "crime", m_qp = "ywxffwhggaqz", m_fly = "ywxffwhggaqz", qp = { "ywxffwhggaqz", "ywxffwhggaq" }, fly = { "ywxffwhggaqz", "ywxffwhggaq" } },
  { text = "失火罪", comment = "〔第二章 第115条〕", type = "crime", m_qp = "shz", m_fly = "uhz", qp = { "shz", "sh" }, fly = { "uhz", "uh" } },
  { text = "过失决水罪", comment = "〔第二章 第115条〕", type = "crime", m_qp = "gsjsz", m_fly = "gujuz", qp = { "gsjsz", "gsjs" }, fly = { "gujuz", "guju" } },
  { text = "过失爆炸罪", comment = "〔第二章 第115条〕", type = "crime", m_qp = "gsbzz", m_fly = "gubvz", qp = { "gsbzz", "gsbz" }, fly = { "gubvz", "gubv" } },
  { text = "过失投放危险物质罪", comment = "〔第二章 第115条〕", type = "crime", m_qp = "gstfwxwzz", m_fly = "gutfwxwvz", qp = { "gstfwxwzz", "gstfwxwz" }, fly = { "gutfwxwvz", "gutfwxwv" } },
  { text = "过失以危险方法危害公共安全罪", comment = "〔第二章 第115条〕", type = "crime", m_qp = "gsywxffwhggaqz", m_fly = "guywxffwhggaqz", qp = { "gsywxffwhggaqz", "gsywxffwhggaq" }, fly = { "guywxffwhggaqz", "guywxffwhggaq" } },
  { text = "破坏交通工具罪", comment = "〔第二章 第116条、第119条〕", type = "crime", m_qp = "phjtgjz", m_fly = "phjtgjz", qp = { "phjtgjz", "phjtgj" }, fly = { "phjtgjz", "phjtgj" } },
  { text = "破坏交通设施罪", comment = "〔第二章 第117条、第119条〕", type = "crime", m_qp = "phjtssz", m_fly = "phjtuuz", qp = { "phjtssz", "phjtss" }, fly = { "phjtuuz", "phjtuu" } },
  { text = "破坏电力设备罪", comment = "〔第二章 第118条、第119条〕", type = "crime", m_qp = "phdlsbz", m_fly = "phdlubz", qp = { "phdlsbz", "phdlsb" }, fly = { "phdlubz", "phdlub" } },
  { text = "破坏易燃易爆设备罪", comment = "〔第二章 第118条、第119条〕", type = "crime", m_qp = "phyrybsbz", m_fly = "phyrybubz", qp = { "phyrybsbz", "phyrybsb" }, fly = { "phyrybubz", "phyrybub" } },
  { text = "过失损坏交通工具罪", comment = "〔第二章 第119条〕", type = "crime", m_qp = "gsshjtgjz", m_fly = "gushjtgjz", qp = { "gsshjtgjz", "gsshjtgj" }, fly = { "gushjtgjz", "gushjtgj" } },
  { text = "过失损坏交通设施罪", comment = "〔第二章 第119条〕", type = "crime", m_qp = "gsshjtssz", m_fly = "gushjtuuz", qp = { "gsshjtssz", "gsshjtss" }, fly = { "gushjtuuz", "gushjtuu" } },
  { text = "过失损坏电力设备罪", comment = "〔第二章 第119条〕", type = "crime", m_qp = "gsshdlsbz", m_fly = "gushdlubz", qp = { "gsshdlsbz", "gsshdlsb" }, fly = { "gushdlubz", "gushdlub" } },
  { text = "过失损坏易燃易爆设备罪", comment = "〔第二章 第119条〕", type = "crime", m_qp = "gsshyrybsbz", m_fly = "gushyrybubz", qp = { "gsshyrybsbz", "gsshyrybsb" }, fly = { "gushyrybubz", "gushyrybub" } },
  { text = "组织、领导、参加恐怖组织罪", comment = "〔第二章 第120条〕", type = "crime", m_qp = "zzldcjkbzzz", m_fly = "zvldcjkbzvz", qp = { "zzldcjkbzzz", "zzldcjkbzz", "zz", "ld", "cjkbzz" }, fly = { "zvldcjkbzvz", "zvldcjkbzv", "zv", "ld", "cjkbzv" } },
  { text = "帮助恐怖活动罪", comment = "〔第二章 第120条之一〕", type = "crime", m_qp = "bzkbhdz", m_fly = "bvkbhdz", qp = { "bzkbhdz", "bzkbhd" }, fly = { "bvkbhdz", "bvkbhd" } },
  { text = "准备实施恐怖活动罪", comment = "〔第二章 第120条之二〕", type = "crime", m_qp = "zbsskbhdz", m_fly = "vbuukbhdz", qp = { "zbsskbhdz", "zbsskbhd" }, fly = { "vbuukbhdz", "vbuukbhd" } },
  { text = "宣扬恐怖主义、极端主义、煽动实施恐怖活动罪", comment = "〔第二章 第120条之三〕", type = "crime", m_qp = "xykbzyjdzysdsskbhdz", m_fly = "xykbvyjdvyuduukbhdz", qp = { "xykbzyjdzysdsskbhdz", "xykbzyjdzysdsskbhd", "xykbzy", "jdzy", "sdsskbhd" }, fly = { "xykbvyjdvyuduukbhdz", "xykbvyjdvyuduukbhd", "xykbvy", "jdvy", "uduukbhd" } },
  { text = "利用极端主义破坏法律实施罪", comment = "〔第二章 第120条之四〕", type = "crime", m_qp = "lyjdzyphflssz", m_fly = "lyjdvyphfluuz", qp = { "lyjdzyphflssz", "lyjdzyphflss" }, fly = { "lyjdvyphfluuz", "lyjdvyphfluu" } },
  { text = "强制穿戴宣扬恐怖主义、极端主义服饰、标志罪", comment = "〔第二章 第120条之五〕", type = "crime", m_qp = "qzcdxykbzyjdzyfsbzz", m_fly = "qvidxykbvyjdvyfubvz", qp = { "qzcdxykbzyjdzyfsbzz", "qzcdxykbzyjdzyfsbz", "qzcdxykbzy", "jdzyfs", "bz" }, fly = { "qvidxykbvyjdvyfubvz", "qvidxykbvyjdvyfubv", "qvidxykbvy", "jdvyfu", "bv" } },
  { text = "非法持有宣扬恐怖主义、极端主义物品罪", comment = "〔第二章 第120条之六〕", type = "crime", m_qp = "ffcyxykbzyjdzywpz", m_fly = "ffiyxykbvyjdvywpz", qp = { "ffcyxykbzyjdzywpz", "ffcyxykbzyjdzywp", "ffcyxykbzy", "jdzywp" }, fly = { "ffiyxykbvyjdvywpz", "ffiyxykbvyjdvywp", "ffiyxykbvy", "jdvywp" } },
  { text = "劫持航空器罪", comment = "〔第二章 第121条〕", type = "crime", m_qp = "jchkqz", m_fly = "jihkqz", qp = { "jchkqz", "jchkq" }, fly = { "jihkqz", "jihkq" } },
  { text = "劫持船只、汽车罪", comment = "〔第二章 第122条〕", type = "crime", m_qp = "jcczqcz", m_fly = "jiivqiz", qp = { "jcczqcz", "jcczqc", "jccz", "qc" }, fly = { "jiivqiz", "jiivqi", "jiiv", "qi" } },
  { text = "暴力危及飞行安全罪", comment = "〔第二章 第123条〕", type = "crime", m_qp = "blwjfxaqz", m_fly = "blwjfxaqz", qp = { "blwjfxaqz", "blwjfxaq" }, fly = { "blwjfxaqz", "blwjfxaq" } },
  { text = "破坏广播电视设施、公用电信设施罪", comment = "〔第二章 第124条〕", type = "crime", m_qp = "phgbdsssgydxssz", m_fly = "phgbduuugydxuuz", qp = { "phgbdsssgydxssz", "phgbdsssgydxss", "phgbdsss", "gydxss" }, fly = { "phgbduuugydxuuz", "phgbduuugydxuu", "phgbduuu", "gydxuu" } },
  { text = "过失损坏广播电视设施、公用电信设施罪", comment = "〔第二章 第124条〕", type = "crime", m_qp = "gsshgbdsssgydxssz", m_fly = "gushgbduuugydxuuz", qp = { "gsshgbdsssgydxssz", "gsshgbdsssgydxss", "gsshgbdsss", "gydxss" }, fly = { "gushgbduuugydxuuz", "gushgbduuugydxuu", "gushgbduuu", "gydxuu" } },
  { text = "非法制造、买卖、运输、邮寄、储存枪支、弹药、爆炸物罪", comment = "〔第二章 第125条〕", type = "crime", m_qp = "ffzzmmysyjccqzdybzwz", m_fly = "ffvzmmyuyjicqvdybvwz", qp = { "ffzzmmysyjccqzdybzwz", "ffzzmmysyjccqzdybzw", "ffzz", "mm", "ys", "yj", "ccqz", "dy", "bzw" }, fly = { "ffvzmmyuyjicqvdybvwz", "ffvzmmyuyjicqvdybvw", "ffvz", "mm", "yu", "yj", "icqv", "dy", "bvw" } },
  { text = "非法制造、买卖、运输、储存危险物质罪", comment = "〔第二章 第125条〕", type = "crime", m_qp = "ffzzmmysccwxwzz", m_fly = "ffvzmmyuicwxwvz", qp = { "ffzzmmysccwxwzz", "ffzzmmysccwxwz", "ffzz", "mm", "ys", "ccwxwz" }, fly = { "ffvzmmyuicwxwvz", "ffvzmmyuicwxwv", "ffvz", "mm", "yu", "icwxwv" } },
  { text = "违规制造、销售枪支罪", comment = "〔第二章 第126条〕", type = "crime", m_qp = "wgzzxsqzz", m_fly = "wgvzxuqvz", qp = { "wgzzxsqzz", "wgzzxsqz", "wgzz", "xsqz" }, fly = { "wgvzxuqvz", "wgvzxuqv", "wgvz", "xuqv" } },
  { text = "盗窃、抢夺枪支、弹药、爆炸物、危险物质罪", comment = "〔第二章 第127条〕", type = "crime", m_qp = "dqqdqzdybzwwxwzz", m_fly = "dqqdqvdybvwwxwvz", qp = { "dqqdqzdybzwwxwzz", "dqqdqzdybzwwxwz", "dq", "qdqz", "dy", "bzw", "wxwz" }, fly = { "dqqdqvdybvwwxwvz", "dqqdqvdybvwwxwv", "dq", "qdqv", "dy", "bvw", "wxwv" } },
  { text = "抢劫枪支、弹药、爆炸物、危险物质罪", comment = "〔第二章 第127条〕", type = "crime", m_qp = "qjqzdybzwwxwzz", m_fly = "qjqvdybvwwxwvz", qp = { "qjqzdybzwwxwzz", "qjqzdybzwwxwz", "qjqz", "dy", "bzw", "wxwz" }, fly = { "qjqvdybvwwxwvz", "qjqvdybvwwxwv", "qjqv", "dy", "bvw", "wxwv" } },
  { text = "非法持有、私藏枪支、弹药罪", comment = "〔第二章 第128条〕", type = "crime", m_qp = "ffcyscqzdyz", m_fly = "ffiyscqvdyz", qp = { "ffcyscqzdyz", "ffcyscqzdy", "ffcy", "scqz", "dy" }, fly = { "ffiyscqvdyz", "ffiyscqvdy", "ffiy", "scqv", "dy" } },
  { text = "非法出租、出借枪支罪", comment = "〔第二章 第128条〕", type = "crime", m_qp = "ffczcjqzz", m_fly = "ffizijqvz", qp = { "ffczcjqzz", "ffczcjqz", "ffcz", "cjqz" }, fly = { "ffizijqvz", "ffizijqv", "ffiz", "ijqv" } },
  { text = "丢失枪支不报罪", comment = "〔第二章 第129条〕", type = "crime", m_qp = "dsqzbbz", m_fly = "duqvbbz", qp = { "dsqzbbz", "dsqzbb" }, fly = { "duqvbbz", "duqvbb" } },
  { text = "非法携带枪支、弹药、管制刀具、危险物品危及公共安全罪", comment = "〔第二章 第130条〕", type = "crime", m_qp = "ffxdqzdygzdjwxwpwjggaqz", m_fly = "ffxdqvdygvdjwxwpwjggaqz", qp = { "ffxdqzdygzdjwxwpwjggaqz", "ffxdqzdygzdjwxwpwjggaq", "ffxdqz", "dy", "gzdj", "wxwpwjggaq" }, fly = { "ffxdqvdygvdjwxwpwjggaqz", "ffxdqvdygvdjwxwpwjggaq", "ffxdqv", "dy", "gvdj", "wxwpwjggaq" } },
  { text = "重大飞行事故罪", comment = "〔第二章 第131条〕", type = "crime", m_qp = "zdfxsgz", m_fly = "vdfxugz", qp = { "zdfxsgz", "zdfxsg" }, fly = { "vdfxugz", "vdfxug" } },
  { text = "铁路运营安全事故罪", comment = "〔第二章 第132条〕", type = "crime", m_qp = "tlyyaqsgz", m_fly = "tlyyaqugz", qp = { "tlyyaqsgz", "tlyyaqsg" }, fly = { "tlyyaqugz", "tlyyaqug" } },
  { text = "交通肇事罪", comment = "〔第二章 第133条〕", type = "crime", m_qp = "jtzsz", m_fly = "jtvuz", qp = { "jtzsz", "jtzs" }, fly = { "jtvuz", "jtvu" } },
  { text = "危险驾驶罪", comment = "〔第二章 第133条之一〕", type = "crime", m_qp = "wxjsz", m_fly = "wxjuz", qp = { "wxjsz", "wxjs" }, fly = { "wxjuz", "wxju" } },
  { text = "妨害安全驾驶罪", comment = "〔第二章 第133条之二〕", type = "crime", m_qp = "fhaqjsz", m_fly = "fhaqjuz", qp = { "fhaqjsz", "fhaqjs" }, fly = { "fhaqjuz", "fhaqju" } },
  { text = "重大责任事故罪", comment = "〔第二章 第134条〕", type = "crime", m_qp = "zdzrsgz", m_fly = "vdzrugz", qp = { "zdzrsgz", "zdzrsg" }, fly = { "vdzrugz", "vdzrug" } },
  { text = "强令、组织他人违章冒险作业罪", comment = "〔第二章 第134条〕", type = "crime", m_qp = "qlzztrwzmxzyz", m_fly = "qlzvtrwvmxzyz", qp = { "qlzztrwzmxzyz", "qlzztrwzmxzy", "ql", "zztrwzmxzy" }, fly = { "qlzvtrwvmxzyz", "qlzvtrwvmxzy", "ql", "zvtrwvmxzy" } },
  { text = "危险作业罪", comment = "〔第二章 第134条之一〕", type = "crime", m_qp = "wxzyz", m_fly = "wxzyz", qp = { "wxzyz", "wxzy" }, fly = { "wxzyz", "wxzy" } },
  { text = "重大劳动安全事故罪", comment = "〔第二章 第135条〕", type = "crime", m_qp = "zdldaqsgz", m_fly = "vdldaqugz", qp = { "zdldaqsgz", "zdldaqsg" }, fly = { "vdldaqugz", "vdldaqug" } },
  { text = "大型群众性活动重大安全事故罪", comment = "〔第二章 第135条之一〕", type = "crime", m_qp = "dxqzxhdzdaqsgz", m_fly = "dxqvxhdvdaqugz", qp = { "dxqzxhdzdaqsgz", "dxqzxhdzdaqsg" }, fly = { "dxqvxhdvdaqugz", "dxqvxhdvdaqug" } },
  { text = "危险物品肇事罪", comment = "〔第二章 第136条〕", type = "crime", m_qp = "wxwpzsz", m_fly = "wxwpvuz", qp = { "wxwpzsz", "wxwpzs" }, fly = { "wxwpvuz", "wxwpvu" } },
  { text = "工程重大安全事故罪", comment = "〔第二章 第137条〕", type = "crime", m_qp = "gczdaqsgz", m_fly = "givdaqugz", qp = { "gczdaqsgz", "gczdaqsg" }, fly = { "givdaqugz", "givdaqug" } },
  { text = "教育设施重大安全事故罪", comment = "〔第二章 第138条〕", type = "crime", m_qp = "jysszdaqsgz", m_fly = "jyuuvdaqugz", qp = { "jysszdaqsgz", "jysszdaqsg" }, fly = { "jyuuvdaqugz", "jyuuvdaqug" } },
  { text = "消防责任事故罪", comment = "〔第二章 第139条〕", type = "crime", m_qp = "xfzrsgz", m_fly = "xfzrugz", qp = { "xfzrsgz", "xfzrsg" }, fly = { "xfzrugz", "xfzrug" } },
  { text = "不报、谎报安全事故罪", comment = "〔第二章 第139条之一〕", type = "crime", m_qp = "bbhbaqsgz", m_fly = "bbhbaqugz", qp = { "bbhbaqsgz", "bbhbaqsg", "bb", "hbaqsg" }, fly = { "bbhbaqugz", "bbhbaqug", "bb", "hbaqug" } },
  { text = "生产、销售伪劣产品罪", comment = "〔第三章第一节 第140条〕", type = "crime", m_qp = "scxswlcpz", m_fly = "uixuwlipz", qp = { "scxswlcpz", "scxswlcp", "sc", "xswlcp" }, fly = { "uixuwlipz", "uixuwlip", "ui", "xuwlip" } },
  { text = "生产、销售、提供假药罪", comment = "〔第三章第一节 第141条〕", type = "crime", m_qp = "scxstgjyz", m_fly = "uixutgjyz", qp = { "scxstgjyz", "scxstgjy", "sc", "xs", "tgjy" }, fly = { "uixutgjyz", "uixutgjy", "ui", "xu", "tgjy" } },
  { text = "生产、销售、提供劣药罪", comment = "〔第三章第一节 第142条〕", type = "crime", m_qp = "scxstglyz", m_fly = "uixutglyz", qp = { "scxstglyz", "scxstgly", "sc", "xs", "tgly" }, fly = { "uixutglyz", "uixutgly", "ui", "xu", "tgly" } },
  { text = "妨害药品管理罪", comment = "〔第三章第一节 第142条之一〕", type = "crime", m_qp = "fhypglz", m_fly = "fhypglz", qp = { "fhypglz", "fhypgl" }, fly = { "fhypglz", "fhypgl" } },
  { text = "生产、销售不符合安全标准的食品罪", comment = "〔第三章第一节 第143条〕", type = "crime", m_qp = "scxsbfhaqbzdspz", m_fly = "uixubfhaqbvdupz", qp = { "scxsbfhaqbzdspz", "scxsbfhaqbzdsp", "sc", "xsbfhaqbzdsp" }, fly = { "uixubfhaqbvdupz", "uixubfhaqbvdup", "ui", "xubfhaqbvdup" } },
  { text = "生产、销售有毒、有害食品罪", comment = "〔第三章第一节 第144条〕", type = "crime", m_qp = "scxsydyhspz", m_fly = "uixuydyhupz", qp = { "scxsydyhspz", "scxsydyhsp", "sc", "xsyd", "yhsp" }, fly = { "uixuydyhupz", "uixuydyhup", "ui", "xuyd", "yhup" } },
  { text = "生产、销售不符合标准的医用器材罪", comment = "〔第三章第一节 第145条〕", type = "crime", m_qp = "scxsbfhbzdyyqcz", m_fly = "uixubfhbvdyyqcz", qp = { "scxsbfhbzdyyqcz", "scxsbfhbzdyyqc", "sc", "xsbfhbzdyyqc" }, fly = { "uixubfhbvdyyqcz", "uixubfhbvdyyqc", "ui", "xubfhbvdyyqc" } },
  { text = "生产、销售不符合安全标准的产品罪", comment = "〔第三章第一节 第146条〕", type = "crime", m_qp = "scxsbfhaqbzdcpz", m_fly = "uixubfhaqbvdipz", qp = { "scxsbfhaqbzdcpz", "scxsbfhaqbzdcp", "sc", "xsbfhaqbzdcp" }, fly = { "uixubfhaqbvdipz", "uixubfhaqbvdip", "ui", "xubfhaqbvdip" } },
  { text = "生产、销售伪劣农药、兽药、化肥、种子罪", comment = "〔第三章第一节 第147条〕", type = "crime", m_qp = "scxswlnysyhfzzz", m_fly = "uixuwlnyuyhfvzz", qp = { "scxswlnysyhfzzz", "scxswlnysyhfzz", "sc", "xswlny", "sy", "hf", "zz" }, fly = { "uixuwlnyuyhfvzz", "uixuwlnyuyhfvz", "ui", "xuwlny", "uy", "hf", "vz" } },
  { text = "生产、销售不符合卫生标准的化妆品罪", comment = "〔第三章第一节 第148条〕", type = "crime", m_qp = "scxsbfhwsbzdhzpz", m_fly = "uixubfhwubvdhvpz", qp = { "scxsbfhwsbzdhzpz", "scxsbfhwsbzdhzp", "sc", "xsbfhwsbzdhzp" }, fly = { "uixubfhwubvdhvpz", "uixubfhwubvdhvp", "ui", "xubfhwubvdhvp" } },
  { text = "走私武器、弹药罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zswqdyz", m_fly = "zswqdyz", qp = { "zswqdyz", "zswqdy", "zswq", "dy" }, fly = { "zswqdyz", "zswqdy", "zswq", "dy" } },
  { text = "走私核材料罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zshclz", m_fly = "zshclz", qp = { "zshclz", "zshcl" }, fly = { "zshclz", "zshcl" } },
  { text = "走私假币罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zsjbz", m_fly = "zsjbz", qp = { "zsjbz", "zsjb" }, fly = { "zsjbz", "zsjb" } },
  { text = "走私文物罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zswwz", m_fly = "zswwz", qp = { "zswwz", "zsww" }, fly = { "zswwz", "zsww" } },
  { text = "走私贵重金属罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zsgzjsz", m_fly = "zsgvjuz", qp = { "zsgzjsz", "zsgzjs" }, fly = { "zsgvjuz", "zsgvju" } },
  { text = "走私珍贵动物、珍贵动物制品罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zszgdwzgdwzpz", m_fly = "zsvgdwvgdwvpz", qp = { "zszgdwzgdwzpz", "zszgdwzgdwzp", "zszgdw", "zgdwzp" }, fly = { "zsvgdwvgdwvpz", "zsvgdwvgdwvp", "zsvgdw", "vgdwvp" } },
  { text = "走私国家禁止进出口的货物、物品罪", comment = "〔第三章第二节 第151条〕", type = "crime", m_qp = "zsgjjzjckdhwwpz", m_fly = "zsgjjvjikdhwwpz", qp = { "zsgjjzjckdhwwpz", "zsgjjzjckdhwwp", "zsgjjzjckdhw", "wp" }, fly = { "zsgjjvjikdhwwpz", "zsgjjvjikdhwwp", "zsgjjvjikdhw", "wp" } },
  { text = "走私淫秽物品罪", comment = "〔第三章第二节 第152条〕", type = "crime", m_qp = "zsyhwpz", m_fly = "zsyhwpz", qp = { "zsyhwpz", "zsyhwp" }, fly = { "zsyhwpz", "zsyhwp" } },
  { text = "走私废物罪", comment = "〔第三章第二节 第152条〕", type = "crime", m_qp = "zsfwz", m_fly = "zsfwz", qp = { "zsfwz", "zsfw" }, fly = { "zsfwz", "zsfw" } },
  { text = "走私普通货物、物品罪", comment = "〔第三章第二节 第153条〕", type = "crime", m_qp = "zspthwwpz", m_fly = "zspthwwpz", qp = { "zspthwwpz", "zspthwwp", "zspthw", "wp" }, fly = { "zspthwwpz", "zspthwwp", "zspthw", "wp" } },
  { text = "虚报注册资本罪", comment = "〔第三章第三节 第158条〕", type = "crime", m_qp = "xbzczbz", m_fly = "xbvczbz", qp = { "xbzczbz", "xbzczb" }, fly = { "xbvczbz", "xbvczb" } },
  { text = "虚假出资、抽逃出资罪", comment = "〔第三章第三节 第159条〕", type = "crime", m_qp = "xjczctczz", m_fly = "xjizitizz", qp = { "xjczctczz", "xjczctcz", "xjcz", "ctcz" }, fly = { "xjizitizz", "xjizitiz", "xjiz", "itiz" } },
  { text = "欺诈发行证券罪", comment = "〔第三章第三节 第160条〕", type = "crime", m_qp = "qzfxzqz", m_fly = "qvfxvqz", qp = { "qzfxzqz", "qzfxzq" }, fly = { "qvfxvqz", "qvfxvq" } },
  { text = "违规披露、不披露重要信息罪", comment = "〔第三章第三节 第161条〕", type = "crime", m_qp = "wgplbplzyxxz", m_fly = "wgplbplvyxxz", qp = { "wgplbplzyxxz", "wgplbplzyxx", "wgpl", "bplzyxx" }, fly = { "wgplbplvyxxz", "wgplbplvyxx", "wgpl", "bplvyxx" } },
  { text = "妨害清算罪", comment = "〔第三章第三节 第162条〕", type = "crime", m_qp = "fhqsz", m_fly = "fhqsz", qp = { "fhqsz", "fhqs" }, fly = { "fhqsz", "fhqs" } },
  { text = "隐匿、故意销毁会计凭证、会计账簿、财务会计报告罪", comment = "〔第三章第三节 第162条之一〕", type = "crime", m_qp = "yngyxhkjpzkjzbcwkjbgz", m_fly = "yngyxhkjpvkjvbcwkjbgz", qp = { "yngyxhkjpzkjzbcwkjbgz", "yngyxhkjpzkjzbcwkjbg", "yn", "gyxhkjpz", "kjzb", "cwkjbg" }, fly = { "yngyxhkjpvkjvbcwkjbgz", "yngyxhkjpvkjvbcwkjbg", "yn", "gyxhkjpv", "kjvb", "cwkjbg" } },
  { text = "虚假破产罪", comment = "〔第三章第三节 第162条之二〕", type = "crime", m_qp = "xjpcz", m_fly = "xjpiz", qp = { "xjpcz", "xjpc" }, fly = { "xjpiz", "xjpi" } },
  { text = "非国家工作人员受贿罪", comment = "〔第三章第三节 第163条、第184条〕", type = "crime", m_qp = "fgjgzryshz", m_fly = "fgjgzryuhz", qp = { "fgjgzryshz", "fgjgzrysh" }, fly = { "fgjgzryuhz", "fgjgzryuh" } },
  { text = "对非国家工作人员行贿罪", comment = "〔第三章第三节 第164条〕", type = "crime", m_qp = "dfgjgzryxhz", m_fly = "dfgjgzryxhz", qp = { "dfgjgzryxhz", "dfgjgzryxh" }, fly = { "dfgjgzryxhz", "dfgjgzryxh" } },
  { text = "对外国公职人员、国际公共组织官员行贿罪", comment = "〔第三章第三节 第164条〕", type = "crime", m_qp = "dwggzrygjggzzgyxhz", m_fly = "dwggvrygjggzvgyxhz", qp = { "dwggzrygjggzzgyxhz", "dwggzrygjggzzgyxh", "dwggzry", "gjggzzgyxh" }, fly = { "dwggvrygjggzvgyxhz", "dwggvrygjggzvgyxh", "dwggvry", "gjggzvgyxh" } },
  { text = "非法经营同类营业罪", comment = "〔第三章第三节 第165条〕", type = "crime", m_qp = "ffjytlyyz", m_fly = "ffjytlyyz", qp = { "ffjytlyyz", "ffjytlyy" }, fly = { "ffjytlyyz", "ffjytlyy" } },
  { text = "为亲友非法牟利罪", comment = "〔第三章第三节 第166条〕", type = "crime", m_qp = "wqyffmlz", m_fly = "wqyffmlz", qp = { "wqyffmlz", "wqyffml" }, fly = { "wqyffmlz", "wqyffml" } },
  { text = "签订、履行合同失职被骗罪", comment = "〔第三章第三节 第167条〕", type = "crime", m_qp = "qdlxhtszbpz", m_fly = "qdlxhtuvbpz", qp = { "qdlxhtszbpz", "qdlxhtszbp", "qd", "lxhtszbp" }, fly = { "qdlxhtuvbpz", "qdlxhtuvbp", "qd", "lxhtuvbp" } },
  { text = "国有公司、企业、事业单位人员失职罪", comment = "〔第三章第三节 第168条〕", type = "crime", m_qp = "gygsqysydwryszz", m_fly = "gygsqyuydwryuvz", qp = { "gygsqysydwryszz", "gygsqysydwrysz", "gygs", "qy", "sydwrysz" }, fly = { "gygsqyuydwryuvz", "gygsqyuydwryuv", "gygs", "qy", "uydwryuv" } },
  { text = "国有公司、企业、事业单位人员滥用职权罪", comment = "〔第三章第三节 第168条〕", type = "crime", m_qp = "gygsqysydwrylyzqz", m_fly = "gygsqyuydwrylyvqz", qp = { "gygsqysydwrylyzqz", "gygsqysydwrylyzq", "gygs", "qy", "sydwrylyzq" }, fly = { "gygsqyuydwrylyvqz", "gygsqyuydwrylyvq", "gygs", "qy", "uydwrylyvq" } },
  { text = "徇私舞弊低价折股、出售国有资产罪", comment = "〔第三章第三节 第169条〕", type = "crime", m_qp = "xswbdjzgcsgyzcz", m_fly = "xswbdjvgiugyziz", qp = { "xswbdjzgcsgyzcz", "xswbdjzgcsgyzc", "xswbdjzg", "csgyzc" }, fly = { "xswbdjvgiugyziz", "xswbdjvgiugyzi", "xswbdjvg", "iugyzi" } },
  { text = "背信损害上市公司利益罪", comment = "〔第三章第三节 第169条之一〕", type = "crime", m_qp = "bxshssgslyz", m_fly = "bxshuugslyz", qp = { "bxshssgslyz", "bxshssgsly" }, fly = { "bxshuugslyz", "bxshuugsly" } },
  { text = "伪造货币罪", comment = "〔第三章第四节 第170条〕", type = "crime", m_qp = "wzhbz", m_fly = "wzhbz", qp = { "wzhbz", "wzhb" }, fly = { "wzhbz", "wzhb" } },
  { text = "出售、购买、运输假币罪", comment = "〔第三章第四节 第171条〕", type = "crime", m_qp = "csgmysjbz", m_fly = "iugmyujbz", qp = { "csgmysjbz", "csgmysjb", "cs", "gm", "ysjb" }, fly = { "iugmyujbz", "iugmyujb", "iu", "gm", "yujb" } },
  { text = "金融工作人员购买假币、以假币换取货币罪", comment = "〔第三章第四节 第171条〕", type = "crime", m_qp = "jrgzrygmjbyjbhqhbz", m_fly = "jrgzrygmjbyjbhqhbz", qp = { "jrgzrygmjbyjbhqhbz", "jrgzrygmjbyjbhqhb", "jrgzrygmjb", "yjbhqhb" }, fly = { "jrgzrygmjbyjbhqhbz", "jrgzrygmjbyjbhqhb", "jrgzrygmjb", "yjbhqhb" } },
  { text = "持有、使用假币罪", comment = "〔第三章第四节 第172条〕", type = "crime", m_qp = "cysyjbz", m_fly = "iyuyjbz", qp = { "cysyjbz", "cysyjb", "cy", "syjb" }, fly = { "iyuyjbz", "iyuyjb", "iy", "uyjb" } },
  { text = "变造货币罪", comment = "〔第三章第四节 第173条〕", type = "crime", m_qp = "bzhbz", m_fly = "bzhbz", qp = { "bzhbz", "bzhb" }, fly = { "bzhbz", "bzhb" } },
  { text = "擅自设立金融机构罪", comment = "〔第三章第四节 第174条〕", type = "crime", m_qp = "szsljrjgz", m_fly = "uzuljrjgz", qp = { "szsljrjgz", "szsljrjg" }, fly = { "uzuljrjgz", "uzuljrjg" } },
  { text = "伪造、变造、转让金融机构经营许可证、批准文件罪", comment = "〔第三章第四节 第174条〕", type = "crime", m_qp = "wzbzzrjrjgjyxkzpzwjz", m_fly = "wzbzvrjrjgjyxkvpvwjz", qp = { "wzbzzrjrjgjyxkzpzwjz", "wzbzzrjrjgjyxkzpzwj", "wz", "bz", "zrjrjgjyxkz", "pzwj" }, fly = { "wzbzvrjrjgjyxkvpvwjz", "wzbzvrjrjgjyxkvpvwj", "wz", "bz", "vrjrjgjyxkv", "pvwj" } },
  { text = "高利转贷罪", comment = "〔第三章第四节 第175条〕", type = "crime", m_qp = "glzdz", m_fly = "glvdz", qp = { "glzdz", "glzd" }, fly = { "glvdz", "glvd" } },
  { text = "骗取贷款、票据承兑、金融票证罪", comment = "〔第三章第四节 第175条之一〕", type = "crime", m_qp = "pqdkpjcdjrpzz", m_fly = "pqdkpjidjrpvz", qp = { "pqdkpjcdjrpzz", "pqdkpjcdjrpz", "pqdk", "pjcd", "jrpz" }, fly = { "pqdkpjidjrpvz", "pqdkpjidjrpv", "pqdk", "pjid", "jrpv" } },
  { text = "非法吸收公众存款罪", comment = "〔第三章第四节 第176条〕", type = "crime", m_qp = "ffxsgzckz", m_fly = "ffxugvckz", qp = { "ffxsgzckz", "ffxsgzck" }, fly = { "ffxugvckz", "ffxugvck" } },
  { text = "伪造、变造金融票证罪", comment = "〔第三章第四节 第177条〕", type = "crime", m_qp = "wzbzjrpzz", m_fly = "wzbzjrpvz", qp = { "wzbzjrpzz", "wzbzjrpz", "wz", "bzjrpz" }, fly = { "wzbzjrpvz", "wzbzjrpv", "wz", "bzjrpv" } },
  { text = "妨害信用卡管理罪", comment = "〔第三章第四节 第177条之一〕", type = "crime", m_qp = "fhxykglz", m_fly = "fhxykglz", qp = { "fhxykglz", "fhxykgl" }, fly = { "fhxykglz", "fhxykgl" } },
  { text = "窃取、收买、非法提供信用卡信息罪", comment = "〔第三章第四节 第177条之一〕", type = "crime", m_qp = "qqsmfftgxykxxz", m_fly = "qqumfftgxykxxz", qp = { "qqsmfftgxykxxz", "qqsmfftgxykxx", "qq", "sm", "fftgxykxx" }, fly = { "qqumfftgxykxxz", "qqumfftgxykxx", "qq", "um", "fftgxykxx" } },
  { text = "伪造、变造国家有价证券罪", comment = "〔第三章第四节 第178条〕", type = "crime", m_qp = "wzbzgjyjzqz", m_fly = "wzbzgjyjvqz", qp = { "wzbzgjyjzqz", "wzbzgjyjzq", "wz", "bzgjyjzq" }, fly = { "wzbzgjyjvqz", "wzbzgjyjvq", "wz", "bzgjyjvq" } },
  { text = "伪造、变造股票、公司、企业债券罪", comment = "〔第三章第四节 第178条〕", type = "crime", m_qp = "wzbzgpgsqyzqz", m_fly = "wzbzgpgsqyvqz", qp = { "wzbzgpgsqyzqz", "wzbzgpgsqyzq", "wz", "bzgp", "gs", "qyzq" }, fly = { "wzbzgpgsqyvqz", "wzbzgpgsqyvq", "wz", "bzgp", "gs", "qyvq" } },
  { text = "擅自发行股票、公司、企业债券罪", comment = "〔第三章第四节 第179条〕", type = "crime", m_qp = "szfxgpgsqyzqz", m_fly = "uzfxgpgsqyvqz", qp = { "szfxgpgsqyzqz", "szfxgpgsqyzq", "szfxgp", "gs", "qyzq" }, fly = { "uzfxgpgsqyvqz", "uzfxgpgsqyvq", "uzfxgp", "gs", "qyvq" } },
  { text = "内幕交易、泄露内幕信息罪", comment = "〔第三章第四节 第180条〕", type = "crime", m_qp = "nmjyxlnmxxz", m_fly = "nmjyxlnmxxz", qp = { "nmjyxlnmxxz", "nmjyxlnmxx", "nmjy", "xlnmxx" }, fly = { "nmjyxlnmxxz", "nmjyxlnmxx", "nmjy", "xlnmxx" } },
  { text = "利用未公开信息交易罪", comment = "〔第三章第四节 第180条〕", type = "crime", m_qp = "lywgkxxjyz", m_fly = "lywgkxxjyz", qp = { "lywgkxxjyz", "lywgkxxjy" }, fly = { "lywgkxxjyz", "lywgkxxjy" } },
  { text = "编造并传播证券、期货交易虚假信息罪", comment = "〔第三章第四节 第181条〕", type = "crime", m_qp = "bzbcbzqqhjyxjxxz", m_fly = "bzbibvqqhjyxjxxz", qp = { "bzbcbzqqhjyxjxxz", "bzbcbzqqhjyxjxx", "bzbcbzq", "qhjyxjxx" }, fly = { "bzbibvqqhjyxjxxz", "bzbibvqqhjyxjxx", "bzbibvq", "qhjyxjxx" } },
  { text = "诱骗投资者买卖证券、期货合约罪", comment = "〔第三章第四节 第181条〕", type = "crime", m_qp = "yptzzmmzqqhhyz", m_fly = "yptzvmmvqqhhyz", qp = { "yptzzmmzqqhhyz", "yptzzmmzqqhhy", "yptzzmmzq", "qhhy" }, fly = { "yptzvmmvqqhhyz", "yptzvmmvqqhhy", "yptzvmmvq", "qhhy" } },
  { text = "操纵证券、期货市场罪", comment = "〔第三章第四节 第182条〕", type = "crime", m_qp = "czzqqhscz", m_fly = "czvqqhuiz", qp = { "czzqqhscz", "czzqqhsc", "czzq", "qhsc" }, fly = { "czvqqhuiz", "czvqqhui", "czvq", "qhui" } },
  { text = "职务侵占罪", comment = "〔第三章第四节 第183条、第271条〕", type = "crime", m_qp = "zwqzz", m_fly = "vwqvz", qp = { "zwqzz", "zwqz" }, fly = { "vwqvz", "vwqv" } },
  { text = "贪污罪", comment = "〔第三章第四节 第183条、第382条、第394条〕", type = "crime", m_qp = "twz", m_fly = "twz", qp = { "twz", "tw" }, fly = { "twz", "tw" } },
  { text = "受贿罪", comment = "〔第三章第四节 第184条、第385条、第388条〕", type = "crime", m_qp = "shz", m_fly = "uhz", qp = { "shz", "sh" }, fly = { "uhz", "uh" } },
  { text = "挪用资金罪", comment = "〔第三章第四节 第185条、第272条〕", type = "crime", m_qp = "nyzjz", m_fly = "nyzjz", qp = { "nyzjz", "nyzj" }, fly = { "nyzjz", "nyzj" } },
  { text = "挪用公款罪", comment = "〔第三章第四节 第185条、第384条〕", type = "crime", m_qp = "nygkz", m_fly = "nygkz", qp = { "nygkz", "nygk" }, fly = { "nygkz", "nygk" } },
  { text = "背信运用受托财产罪", comment = "〔第三章第四节 第185条之一〕", type = "crime", m_qp = "bxyystccz", m_fly = "bxyyutciz", qp = { "bxyystccz", "bxyystcc" }, fly = { "bxyyutciz", "bxyyutci" } },
  { text = "违法运用资金罪", comment = "〔第三章第四节 第185条之一〕", type = "crime", m_qp = "wfyyzjz", m_fly = "wfyyzjz", qp = { "wfyyzjz", "wfyyzj" }, fly = { "wfyyzjz", "wfyyzj" } },
  { text = "违法发放贷款罪", comment = "〔第三章第四节 第186条〕", type = "crime", m_qp = "wfffdkz", m_fly = "wfffdkz", qp = { "wfffdkz", "wfffdk" }, fly = { "wfffdkz", "wfffdk" } },
  { text = "吸收客户资金不入账罪", comment = "〔第三章第四节 第187条〕", type = "crime", m_qp = "xskhzjbrzz", m_fly = "xukhzjbrvz", qp = { "xskhzjbrzz", "xskhzjbrz" }, fly = { "xukhzjbrvz", "xukhzjbrv" } },
  { text = "违规出具金融票证罪", comment = "〔第三章第四节 第188条〕", type = "crime", m_qp = "wgcjjrpzz", m_fly = "wgijjrpvz", qp = { "wgcjjrpzz", "wgcjjrpz" }, fly = { "wgijjrpvz", "wgijjrpv" } },
  { text = "对违法票据承兑、付款、保证罪", comment = "〔第三章第四节 第189条〕", type = "crime", m_qp = "dwfpjcdfkbzz", m_fly = "dwfpjidfkbvz", qp = { "dwfpjcdfkbzz", "dwfpjcdfkbz", "dwfpjcd", "fk", "bz" }, fly = { "dwfpjidfkbvz", "dwfpjidfkbv", "dwfpjid", "fk", "bv" } },
  { text = "逃汇罪", comment = "〔第三章第四节 第190条〕", type = "crime", m_qp = "thz", m_fly = "thz", qp = { "thz", "th" }, fly = { "thz", "th" } },
  { text = "洗钱罪", comment = "〔第三章第四节 第191条〕", type = "crime", m_qp = "xqz", m_fly = "xqz", qp = { "xqz", "xq" }, fly = { "xqz", "xq" } },
  { text = "集资诈骗罪", comment = "〔第三章第五节 第192条〕", type = "crime", m_qp = "jzzpz", m_fly = "jzvpz", qp = { "jzzpz", "jzzp" }, fly = { "jzvpz", "jzvp" } },
  { text = "贷款诈骗罪", comment = "〔第三章第五节 第193条〕", type = "crime", m_qp = "dkzpz", m_fly = "dkvpz", qp = { "dkzpz", "dkzp" }, fly = { "dkvpz", "dkvp" } },
  { text = "票据诈骗罪", comment = "〔第三章第五节 第194条〕", type = "crime", m_qp = "pjzpz", m_fly = "pjvpz", qp = { "pjzpz", "pjzp" }, fly = { "pjvpz", "pjvp" } },
  { text = "金融凭证诈骗罪", comment = "〔第三章第五节 第194条〕", type = "crime", m_qp = "jrpzzpz", m_fly = "jrpvvpz", qp = { "jrpzzpz", "jrpzzp" }, fly = { "jrpvvpz", "jrpvvp" } },
  { text = "信用证诈骗罪", comment = "〔第三章第五节 第195条〕", type = "crime", m_qp = "xyzzpz", m_fly = "xyvvpz", qp = { "xyzzpz", "xyzzp" }, fly = { "xyvvpz", "xyvvp" } },
  { text = "信用卡诈骗罪", comment = "〔第三章第五节 第196条〕", type = "crime", m_qp = "xykzpz", m_fly = "xykvpz", qp = { "xykzpz", "xykzp" }, fly = { "xykvpz", "xykvp" } },
  { text = "有价证券诈骗罪", comment = "〔第三章第五节 第197条〕", type = "crime", m_qp = "yjzqzpz", m_fly = "yjvqvpz", qp = { "yjzqzpz", "yjzqzp" }, fly = { "yjvqvpz", "yjvqvp" } },
  { text = "保险诈骗罪", comment = "〔第三章第五节 第198条〕", type = "crime", m_qp = "bxzpz", m_fly = "bxvpz", qp = { "bxzpz", "bxzp" }, fly = { "bxvpz", "bxvp" } },
  { text = "逃税罪", comment = "〔第三章第六节 第201条〕", type = "crime", m_qp = "tsz", m_fly = "tuz", qp = { "tsz", "ts" }, fly = { "tuz", "tu" } },
  { text = "抗税罪", comment = "〔第三章第六节 第202条〕", type = "crime", m_qp = "ksz", m_fly = "kuz", qp = { "ksz", "ks" }, fly = { "kuz", "ku" } },
  { text = "逃避追缴欠税罪", comment = "〔第三章第六节 第203条〕", type = "crime", m_qp = "tbzjqsz", m_fly = "tbvjquz", qp = { "tbzjqsz", "tbzjqs" }, fly = { "tbvjquz", "tbvjqu" } },
  { text = "骗取出口退税罪", comment = "〔第三章第六节 第204条〕", type = "crime", m_qp = "pqcktsz", m_fly = "pqiktuz", qp = { "pqcktsz", "pqckts" }, fly = { "pqiktuz", "pqiktu" } },
  { text = "虚开增值税专用发票、用于骗取出口退税、抵扣税款发票罪", comment = "〔第三章第六节 第205条〕", type = "crime", m_qp = "xkzzszyfpyypqcktsdkskfpz", m_fly = "xkzvuvyfpyypqiktudkukfpz", qp = { "xkzzszyfpyypqcktsdkskfpz", "xkzzszyfpyypqcktsdkskfp", "xkzzszyfp", "yypqckts", "dkskfp" }, fly = { "xkzvuvyfpyypqiktudkukfpz", "xkzvuvyfpyypqiktudkukfp", "xkzvuvyfp", "yypqiktu", "dkukfp" } },
  { text = "虚开发票罪", comment = "〔第三章第六节 第205条之一〕", type = "crime", m_qp = "xkfpz", m_fly = "xkfpz", qp = { "xkfpz", "xkfp" }, fly = { "xkfpz", "xkfp" } },
  { text = "伪造、出售伪造的增值税专用发票罪", comment = "〔第三章第六节 第206条〕", type = "crime", m_qp = "wzcswzdzzszyfpz", m_fly = "wziuwzdzvuvyfpz", qp = { "wzcswzdzzszyfpz", "wzcswzdzzszyfp", "wz", "cswzdzzszyfp" }, fly = { "wziuwzdzvuvyfpz", "wziuwzdzvuvyfp", "wz", "iuwzdzvuvyfp" } },
  { text = "非法出售增值税专用发票罪", comment = "〔第三章第六节 第207条〕", type = "crime", m_qp = "ffcszzszyfpz", m_fly = "ffiuzvuvyfpz", qp = { "ffcszzszyfpz", "ffcszzszyfp" }, fly = { "ffiuzvuvyfpz", "ffiuzvuvyfp" } },
  { text = "非法购买增值税专用发票、购买伪造的增值税专用发票罪", comment = "〔第三章第六节 第208条〕", type = "crime", m_qp = "ffgmzzszyfpgmwzdzzszyfpz", m_fly = "ffgmzvuvyfpgmwzdzvuvyfpz", qp = { "ffgmzzszyfpgmwzdzzszyfpz", "ffgmzzszyfpgmwzdzzszyfp", "ffgmzzszyfp", "gmwzdzzszyfp" }, fly = { "ffgmzvuvyfpgmwzdzvuvyfpz", "ffgmzvuvyfpgmwzdzvuvyfp", "ffgmzvuvyfp", "gmwzdzvuvyfp" } },
  { text = "非法制造、出售非法制造的用于骗取出口退税、抵扣税款发票罪", comment = "〔第三章第六节 第209条〕", type = "crime", m_qp = "ffzzcsffzzdyypqcktsdkskfpz", m_fly = "ffvziuffvzdyypqiktudkukfpz", qp = { "ffzzcsffzzdyypqcktsdkskfpz", "ffzzcsffzzdyypqcktsdkskfp", "ffzz", "csffzzdyypqckts", "dkskfp" }, fly = { "ffvziuffvzdyypqiktudkukfpz", "ffvziuffvzdyypqiktudkukfp", "ffvz", "iuffvzdyypqiktu", "dkukfp" } },
  { text = "非法制造、出售非法制造的发票罪", comment = "〔第三章第六节 第209条〕", type = "crime", m_qp = "ffzzcsffzzdfpz", m_fly = "ffvziuffvzdfpz", qp = { "ffzzcsffzzdfpz", "ffzzcsffzzdfp", "ffzz", "csffzzdfp" }, fly = { "ffvziuffvzdfpz", "ffvziuffvzdfp", "ffvz", "iuffvzdfp" } },
  { text = "非法出售用于骗取出口退税、抵扣税款发票罪", comment = "〔第三章第六节 第209条〕", type = "crime", m_qp = "ffcsyypqcktsdkskfpz", m_fly = "ffiuyypqiktudkukfpz", qp = { "ffcsyypqcktsdkskfpz", "ffcsyypqcktsdkskfp", "ffcsyypqckts", "dkskfp" }, fly = { "ffiuyypqiktudkukfpz", "ffiuyypqiktudkukfp", "ffiuyypqiktu", "dkukfp" } },
  { text = "非法出售发票罪", comment = "〔第三章第六节 第209条〕", type = "crime", m_qp = "ffcsfpz", m_fly = "ffiufpz", qp = { "ffcsfpz", "ffcsfp" }, fly = { "ffiufpz", "ffiufp" } },
  { text = "盗窃罪", comment = "〔第三章第六节 第210条、第264条、第265条〕", type = "crime", m_qp = "dqz", m_fly = "dqz", qp = { "dqz", "dq" }, fly = { "dqz", "dq" } },
  { text = "诈骗罪", comment = "〔第三章第六节 第210条、第266条〕", type = "crime", m_qp = "zpz", m_fly = "vpz", qp = { "zpz", "zp" }, fly = { "vpz", "vp" } },
  { text = "持有伪造的发票罪", comment = "〔第三章第六节 第210条之一〕", type = "crime", m_qp = "cywzdfpz", m_fly = "iywzdfpz", qp = { "cywzdfpz", "cywzdfp" }, fly = { "iywzdfpz", "iywzdfp" } },
  { text = "假冒注册商标罪", comment = "〔第三章第七节 第213条〕", type = "crime", m_qp = "jmzcsbz", m_fly = "jmvcubz", qp = { "jmzcsbz", "jmzcsb" }, fly = { "jmvcubz", "jmvcub" } },
  { text = "销售假冒注册商标的商品罪", comment = "〔第三章第七节 第214条〕", type = "crime", m_qp = "xsjmzcsbdspz", m_fly = "xujmvcubdupz", qp = { "xsjmzcsbdspz", "xsjmzcsbdsp" }, fly = { "xujmvcubdupz", "xujmvcubdup" } },
  { text = "非法制造、销售非法制造的注册商标标识罪", comment = "〔第三章第七节 第215条〕", type = "crime", m_qp = "ffzzxsffzzdzcsbbsz", m_fly = "ffvzxuffvzdvcubbuz", qp = { "ffzzxsffzzdzcsbbsz", "ffzzxsffzzdzcsbbs", "ffzz", "xsffzzdzcsbbs" }, fly = { "ffvzxuffvzdvcubbuz", "ffvzxuffvzdvcubbu", "ffvz", "xuffvzdvcubbu" } },
  { text = "假冒专利罪", comment = "〔第三章第七节 第216条〕", type = "crime", m_qp = "jmzlz", m_fly = "jmvlz", qp = { "jmzlz", "jmzl" }, fly = { "jmvlz", "jmvl" } },
  { text = "侵犯著作权罪", comment = "〔第三章第七节 第217条〕", type = "crime", m_qp = "qfzzqz", m_fly = "qfvzqz", qp = { "qfzzqz", "qfzzq" }, fly = { "qfvzqz", "qfvzq" } },
  { text = "销售侵权复制品罪", comment = "〔第三章第七节 第218条〕", type = "crime", m_qp = "xsqqfzpz", m_fly = "xuqqfvpz", qp = { "xsqqfzpz", "xsqqfzp" }, fly = { "xuqqfvpz", "xuqqfvp" } },
  { text = "侵犯商业秘密罪", comment = "〔第三章第七节 第219条〕", type = "crime", m_qp = "qfsymmz", m_fly = "qfuymmz", qp = { "qfsymmz", "qfsymm" }, fly = { "qfuymmz", "qfuymm" } },
  { text = "为境外窃取、刺探、收买、非法提供商业秘密罪", comment = "〔第三章第七节 第219条之一〕", type = "crime", m_qp = "wjwqqctsmfftgsymmz", m_fly = "wjwqqctumfftguymmz", qp = { "wjwqqctsmfftgsymmz", "wjwqqctsmfftgsymm", "wjwqq", "ct", "sm", "fftgsymm" }, fly = { "wjwqqctumfftguymmz", "wjwqqctumfftguymm", "wjwqq", "ct", "um", "fftguymm" } },
  { text = "损害商业信誉、商品声誉罪", comment = "〔第三章第八节 第221条〕", type = "crime", m_qp = "shsyxyspsyz", m_fly = "shuyxyupuyz", qp = { "shsyxyspsyz", "shsyxyspsy", "shsyxy", "spsy" }, fly = { "shuyxyupuyz", "shuyxyupuy", "shuyxy", "upuy" } },
  { text = "虚假广告罪", comment = "〔第三章第八节 第222条〕", type = "crime", m_qp = "xjggz", m_fly = "xjggz", qp = { "xjggz", "xjgg" }, fly = { "xjggz", "xjgg" } },
  { text = "串通投标罪", comment = "〔第三章第八节 第223条〕", type = "crime", m_qp = "cttbz", m_fly = "ittbz", qp = { "cttbz", "cttb" }, fly = { "ittbz", "ittb" } },
  { text = "合同诈骗罪", comment = "〔第三章第八节 第224条〕", type = "crime", m_qp = "htzpz", m_fly = "htvpz", qp = { "htzpz", "htzp" }, fly = { "htvpz", "htvp" } },
  { text = "组织、领导传销活动罪", comment = "〔第三章第八节 第224条之一〕", type = "crime", m_qp = "zzldcxhdz", m_fly = "zvldixhdz", qp = { "zzldcxhdz", "zzldcxhd", "zz", "ldcxhd" }, fly = { "zvldixhdz", "zvldixhd", "zv", "ldixhd" } },
  { text = "非法经营罪", comment = "〔第三章第八节 第225条〕", type = "crime", m_qp = "ffjyz", m_fly = "ffjyz", qp = { "ffjyz", "ffjy" }, fly = { "ffjyz", "ffjy" } },
  { text = "强迫交易罪", comment = "〔第三章第八节 第226条〕", type = "crime", m_qp = "qpjyz", m_fly = "qpjyz", qp = { "qpjyz", "qpjy" }, fly = { "qpjyz", "qpjy" } },
  { text = "伪造、倒卖伪造的有价票证罪", comment = "〔第三章第八节 第227条〕", type = "crime", m_qp = "wzdmwzdyjpzz", m_fly = "wzdmwzdyjpvz", qp = { "wzdmwzdyjpzz", "wzdmwzdyjpz", "wz", "dmwzdyjpz" }, fly = { "wzdmwzdyjpvz", "wzdmwzdyjpv", "wz", "dmwzdyjpv" } },
  { text = "倒卖车票、船票罪", comment = "〔第三章第八节 第227条〕", type = "crime", m_qp = "dmcpcpz", m_fly = "dmipipz", qp = { "dmcpcpz", "dmcpcp", "dmcp", "cp" }, fly = { "dmipipz", "dmipip", "dmip", "ip" } },
  { text = "非法转让、倒卖土地使用权罪", comment = "〔第三章第八节 第228条〕", type = "crime", m_qp = "ffzrdmtdsyqz", m_fly = "ffvrdmtduyqz", qp = { "ffzrdmtdsyqz", "ffzrdmtdsyq", "ffzr", "dmtdsyq" }, fly = { "ffvrdmtduyqz", "ffvrdmtduyq", "ffvr", "dmtduyq" } },
  { text = "提供虚假证明文件罪", comment = "〔第三章第八节 第229条〕", type = "crime", m_qp = "tgxjzmwjz", m_fly = "tgxjvmwjz", qp = { "tgxjzmwjz", "tgxjzmwj" }, fly = { "tgxjvmwjz", "tgxjvmwj" } },
  { text = "出具证明文件重大失实罪", comment = "〔第三章第八节 第229条〕", type = "crime", m_qp = "cjzmwjzdssz", m_fly = "ijvmwjvduuz", qp = { "cjzmwjzdssz", "cjzmwjzdss" }, fly = { "ijvmwjvduuz", "ijvmwjvduu" } },
  { text = "逃避商检罪", comment = "〔第三章第八节 第230条〕", type = "crime", m_qp = "tbsjz", m_fly = "tbujz", qp = { "tbsjz", "tbsj" }, fly = { "tbujz", "tbuj" } },
  { text = "故意杀人罪", comment = "〔第四章 第232条、第289条〕", type = "crime", m_qp = "gysrz", m_fly = "gyurz", qp = { "gysrz", "gysr" }, fly = { "gyurz", "gyur" } },
  { text = "过失致人死亡罪", comment = "〔第四章 第233条〕", type = "crime", m_qp = "gszrswz", m_fly = "guvrswz", qp = { "gszrswz", "gszrsw" }, fly = { "guvrswz", "guvrsw" } },
  { text = "故意伤害罪", comment = "〔第四章 第234条、第289条〕", type = "crime", m_qp = "gyshz", m_fly = "gyuhz", qp = { "gyshz", "gysh" }, fly = { "gyuhz", "gyuh" } },
  { text = "组织出卖人体器官罪", comment = "〔第四章 第234条之一〕", type = "crime", m_qp = "zzcmrtqgz", m_fly = "zvimrtqgz", qp = { "zzcmrtqgz", "zzcmrtqg" }, fly = { "zvimrtqgz", "zvimrtqg" } },
  { text = "过失致人重伤罪", comment = "〔第四章 第235条〕", type = "crime", m_qp = "gszrzsz", m_fly = "guvrvuz", qp = { "gszrzsz", "gszrzs" }, fly = { "guvrvuz", "guvrvu" } },
  { text = "强奸罪", comment = "〔第四章 第236条〕", type = "crime", m_qp = "qjz", m_fly = "qjz", qp = { "qjz", "qj" }, fly = { "qjz", "qj" } },
  { text = "负有照护职责人员性侵罪", comment = "〔第四章 第236条之一〕", type = "crime", m_qp = "fyzhzzryxqz", m_fly = "fyvhvzryxqz", qp = { "fyzhzzryxqz", "fyzhzzryxq" }, fly = { "fyvhvzryxqz", "fyvhvzryxq" } },
  { text = "强制猥亵、侮辱罪", comment = "〔第四章 第237条〕", type = "crime", m_qp = "qzwxwrz", m_fly = "qvwxwrz", qp = { "qzwxwrz", "qzwxwr", "qzwx", "wr" }, fly = { "qvwxwrz", "qvwxwr", "qvwx", "wr" } },
  { text = "猥亵儿童罪", comment = "〔第四章 第237条〕", type = "crime", m_qp = "wxetz", m_fly = "wxetz", qp = { "wxetz", "wxet" }, fly = { "wxetz", "wxet" } },
  { text = "非法拘禁罪", comment = "〔第四章 第238条〕", type = "crime", m_qp = "ffjjz", m_fly = "ffjjz", qp = { "ffjjz", "ffjj" }, fly = { "ffjjz", "ffjj" } },
  { text = "绑架罪", comment = "〔第四章 第239条〕", type = "crime", m_qp = "bjz", m_fly = "bjz", qp = { "bjz", "bj" }, fly = { "bjz", "bj" } },
  { text = "拐卖妇女、儿童罪", comment = "〔第四章 第240条〕", type = "crime", m_qp = "gmfnetz", m_fly = "gmfnetz", qp = { "gmfnetz", "gmfnet", "gmfn", "et" }, fly = { "gmfnetz", "gmfnet", "gmfn", "et" } },
  { text = "收买被拐卖的妇女、儿童罪", comment = "〔第四章 第241条〕", type = "crime", m_qp = "smbgmdfnetz", m_fly = "umbgmdfnetz", qp = { "smbgmdfnetz", "smbgmdfnet", "smbgmdfn", "et" }, fly = { "umbgmdfnetz", "umbgmdfnet", "umbgmdfn", "et" } },
  { text = "妨害公务罪", comment = "〔第四章 第242条、第277条〕", type = "crime", m_qp = "fhgwz", m_fly = "fhgwz", qp = { "fhgwz", "fhgw" }, fly = { "fhgwz", "fhgw" } },
  { text = "聚众阻碍解救被收买的妇女、儿童罪", comment = "〔第四章 第242条〕", type = "crime", m_qp = "jzzajjbsmdfnetz", m_fly = "jvzajjbumdfnetz", qp = { "jzzajjbsmdfnetz", "jzzajjbsmdfnet", "jzzajjbsmdfn", "et" }, fly = { "jvzajjbumdfnetz", "jvzajjbumdfnet", "jvzajjbumdfn", "et" } },
  { text = "诬告陷害罪", comment = "〔第四章 第243条〕", type = "crime", m_qp = "wgxhz", m_fly = "wgxhz", qp = { "wgxhz", "wgxh" }, fly = { "wgxhz", "wgxh" } },
  { text = "强迫劳动罪", comment = "〔第四章 第244条〕", type = "crime", m_qp = "qpldz", m_fly = "qpldz", qp = { "qpldz", "qpld" }, fly = { "qpldz", "qpld" } },
  { text = "雇用童工从事危重劳动罪", comment = "〔第四章 第244条之一〕", type = "crime", m_qp = "gytgcswzldz", m_fly = "gytgcuwvldz", qp = { "gytgcswzldz", "gytgcswzld" }, fly = { "gytgcuwvldz", "gytgcuwvld" } },
  { text = "非法搜查罪", comment = "〔第四章 第245条〕", type = "crime", m_qp = "ffscz", m_fly = "ffsiz", qp = { "ffscz", "ffsc" }, fly = { "ffsiz", "ffsi" } },
  { text = "非法侵入住宅罪", comment = "〔第四章 第245条〕", type = "crime", m_qp = "ffqrzzz", m_fly = "ffqrvvz", qp = { "ffqrzzz", "ffqrzz" }, fly = { "ffqrvvz", "ffqrvv" } },
  { text = "侮辱罪", comment = "〔第四章 第246条〕", type = "crime", m_qp = "wrz", m_fly = "wrz", qp = { "wrz", "wr" }, fly = { "wrz", "wr" } },
  { text = "诽谤罪", comment = "〔第四章 第246条〕", type = "crime", m_qp = "fbz", m_fly = "fbz", qp = { "fbz", "fb" }, fly = { "fbz", "fb" } },
  { text = "刑讯逼供罪", comment = "〔第四章 第247条〕", type = "crime", m_qp = "xxbgz", m_fly = "xxbgz", qp = { "xxbgz", "xxbg" }, fly = { "xxbgz", "xxbg" } },
  { text = "暴力取证罪", comment = "〔第四章 第247条〕", type = "crime", m_qp = "blqzz", m_fly = "blqvz", qp = { "blqzz", "blqz" }, fly = { "blqvz", "blqv" } },
  { text = "虐待被监管人罪", comment = "〔第四章 第248条〕", type = "crime", m_qp = "ndbjgrz", m_fly = "ndbjgrz", qp = { "ndbjgrz", "ndbjgr" }, fly = { "ndbjgrz", "ndbjgr" } },
  { text = "煽动民族仇恨、民族歧视罪", comment = "〔第四章 第249条〕", type = "crime", m_qp = "sdmzchmzqsz", m_fly = "udmzihmzquz", qp = { "sdmzchmzqsz", "sdmzchmzqs", "sdmzch", "mzqs" }, fly = { "udmzihmzquz", "udmzihmzqu", "udmzih", "mzqu" } },
  { text = "出版歧视、侮辱少数民族作品罪", comment = "〔第四章 第250条〕", type = "crime", m_qp = "cbqswrssmzzpz", m_fly = "ibquwruumzzpz", qp = { "cbqswrssmzzpz", "cbqswrssmzzp", "cbqs", "wrssmzzp" }, fly = { "ibquwruumzzpz", "ibquwruumzzp", "ibqu", "wruumzzp" } },
  { text = "非法剥夺公民宗教信仰自由罪", comment = "〔第四章 第251条〕", type = "crime", m_qp = "ffbdgmzjxyzyz", m_fly = "ffbdgmzjxyzyz", qp = { "ffbdgmzjxyzyz", "ffbdgmzjxyzy" }, fly = { "ffbdgmzjxyzyz", "ffbdgmzjxyzy" } },
  { text = "侵犯少数民族风俗习惯罪", comment = "〔第四章 第251条〕", type = "crime", m_qp = "qfssmzfsxgz", m_fly = "qfuumzfsxgz", qp = { "qfssmzfsxgz", "qfssmzfsxg" }, fly = { "qfuumzfsxgz", "qfuumzfsxg" } },
  { text = "侵犯通信自由罪", comment = "〔第四章 第252条〕", type = "crime", m_qp = "qftxzyz", m_fly = "qftxzyz", qp = { "qftxzyz", "qftxzy" }, fly = { "qftxzyz", "qftxzy" } },
  { text = "私自开拆、隐匿、毁弃邮件、电报罪", comment = "〔第四章 第253条〕", type = "crime", m_qp = "szkcynhqyjdbz", m_fly = "szkiynhqyjdbz", qp = { "szkcynhqyjdbz", "szkcynhqyjdb", "szkc", "yn", "hqyj", "db" }, fly = { "szkiynhqyjdbz", "szkiynhqyjdb", "szki", "yn", "hqyj", "db" } },
  { text = "侵犯公民个人信息罪", comment = "〔第四章 第253条之一〕", type = "crime", m_qp = "qfgmgrxxz", m_fly = "qfgmgrxxz", qp = { "qfgmgrxxz", "qfgmgrxx" }, fly = { "qfgmgrxxz", "qfgmgrxx" } },
  { text = "报复陷害罪", comment = "〔第四章 第254条〕", type = "crime", m_qp = "bfxhz", m_fly = "bfxhz", qp = { "bfxhz", "bfxh" }, fly = { "bfxhz", "bfxh" } },
  { text = "打击报复会计、统计人员罪", comment = "〔第四章 第255条〕", type = "crime", m_qp = "djbfkjtjryz", m_fly = "djbfkjtjryz", qp = { "djbfkjtjryz", "djbfkjtjry", "djbfkj", "tjry" }, fly = { "djbfkjtjryz", "djbfkjtjry", "djbfkj", "tjry" } },
  { text = "破坏选举罪", comment = "〔第四章 第256条〕", type = "crime", m_qp = "phxjz", m_fly = "phxjz", qp = { "phxjz", "phxj" }, fly = { "phxjz", "phxj" } },
  { text = "暴力干涉婚姻自由罪", comment = "〔第四章 第257条〕", type = "crime", m_qp = "blgshyzyz", m_fly = "blguhyzyz", qp = { "blgshyzyz", "blgshyzy" }, fly = { "blguhyzyz", "blguhyzy" } },
  { text = "重婚罪", comment = "〔第四章 第258条〕", type = "crime", m_qp = "chz", m_fly = "ihz", qp = { "chz", "ch" }, fly = { "ihz", "ih" } },
  { text = "破坏军婚罪", comment = "〔第四章 第259条〕", type = "crime", m_qp = "phjhz", m_fly = "phjhz", qp = { "phjhz", "phjh" }, fly = { "phjhz", "phjh" } },
  { text = "虐待罪", comment = "〔第四章 第260条〕", type = "crime", m_qp = "ndz", m_fly = "ndz", qp = { "ndz", "nd" }, fly = { "ndz", "nd" } },
  { text = "虐待被监护、看护人罪", comment = "〔第四章 第260条之一〕", type = "crime", m_qp = "ndbjhkhrz", m_fly = "ndbjhkhrz", qp = { "ndbjhkhrz", "ndbjhkhr", "ndbjh", "khr" }, fly = { "ndbjhkhrz", "ndbjhkhr", "ndbjh", "khr" } },
  { text = "遗弃罪", comment = "〔第四章 第261条〕", type = "crime", m_qp = "yqz", m_fly = "yqz", qp = { "yqz", "yq" }, fly = { "yqz", "yq" } },
  { text = "拐骗儿童罪", comment = "〔第四章 第262条〕", type = "crime", m_qp = "gpetz", m_fly = "gpetz", qp = { "gpetz", "gpet" }, fly = { "gpetz", "gpet" } },
  { text = "组织残疾人、儿童乞讨罪", comment = "〔第四章 第262条之一〕", type = "crime", m_qp = "zzcjretqtz", m_fly = "zvcjretqtz", qp = { "zzcjretqtz", "zzcjretqt", "zzcjr", "etqt" }, fly = { "zvcjretqtz", "zvcjretqt", "zvcjr", "etqt" } },
  { text = "组织未成年人进行违反治安管理活动罪", comment = "〔第四章 第262条之二〕", type = "crime", m_qp = "zzwcnrjxwfzaglhdz", m_fly = "zvwinrjxwfvaglhdz", qp = { "zzwcnrjxwfzaglhdz", "zzwcnrjxwfzaglhd" }, fly = { "zvwinrjxwfvaglhdz", "zvwinrjxwfvaglhd" } },
  { text = "抢劫罪", comment = "〔第五章 第263条、第289条〕", type = "crime", m_qp = "qjz", m_fly = "qjz", qp = { "qjz", "qj" }, fly = { "qjz", "qj" } },
  { text = "抢夺罪", comment = "〔第五章 第267条〕", type = "crime", m_qp = "qdz", m_fly = "qdz", qp = { "qdz", "qd" }, fly = { "qdz", "qd" } },
  { text = "聚众哄抢罪", comment = "〔第五章 第268条〕", type = "crime", m_qp = "jzhqz", m_fly = "jvhqz", qp = { "jzhqz", "jzhq" }, fly = { "jvhqz", "jvhq" } },
  { text = "转化的抢劫罪", comment = "〔第五章 第269条〕", type = "crime", m_qp = "zhdqjz", m_fly = "vhdqjz", qp = { "zhdqjz", "zhdqj" }, fly = { "vhdqjz", "vhdqj" } },
  { text = "侵占罪", comment = "〔第五章 第270条〕", type = "crime", m_qp = "qzz", m_fly = "qvz", qp = { "qzz", "qz" }, fly = { "qvz", "qv" } },
  { text = "挪用特定款物罪", comment = "〔第五章 第273条〕", type = "crime", m_qp = "nytdkwz", m_fly = "nytdkwz", qp = { "nytdkwz", "nytdkw" }, fly = { "nytdkwz", "nytdkw" } },
  { text = "敲诈勒索罪", comment = "〔第五章 第274条〕", type = "crime", m_qp = "qzlsz", m_fly = "qvlsz", qp = { "qzlsz", "qzls" }, fly = { "qvlsz", "qvls" } },
  { text = "故意毁坏财物罪", comment = "〔第五章 第275条〕", type = "crime", m_qp = "gyhhcwz", m_fly = "gyhhcwz", qp = { "gyhhcwz", "gyhhcw" }, fly = { "gyhhcwz", "gyhhcw" } },
  { text = "破坏生产经营罪", comment = "〔第五章 第276条〕", type = "crime", m_qp = "phscjyz", m_fly = "phuijyz", qp = { "phscjyz", "phscjy" }, fly = { "phuijyz", "phuijy" } },
  { text = "拒不支付劳动报酬罪", comment = "〔第五章 第276条之一〕", type = "crime", m_qp = "jbzfldbcz", m_fly = "jbvfldbiz", qp = { "jbzfldbcz", "jbzfldbc" }, fly = { "jbvfldbiz", "jbvfldbi" } },
  { text = "袭警罪", comment = "〔第六章第一节 第277条〕", type = "crime", m_qp = "xjz", m_fly = "xjz", qp = { "xjz", "xj" }, fly = { "xjz", "xj" } },
  { text = "煽动暴力抗拒法律实施罪", comment = "〔第六章第一节 第278条〕", type = "crime", m_qp = "sdblkjflssz", m_fly = "udblkjfluuz", qp = { "sdblkjflssz", "sdblkjflss" }, fly = { "udblkjfluuz", "udblkjfluu" } },
  { text = "招摇撞骗罪", comment = "〔第六章第一节 第279条〕", type = "crime", m_qp = "zyzpz", m_fly = "vyvpz", qp = { "zyzpz", "zyzp" }, fly = { "vyvpz", "vyvp" } },
  { text = "伪造、变造、买卖国家机关公文、证件、印章罪", comment = "〔第六章第一节 第280条〕", type = "crime", m_qp = "wzbzmmgjjggwzjyzz", m_fly = "wzbzmmgjjggwvjyvz", qp = { "wzbzmmgjjggwzjyzz", "wzbzmmgjjggwzjyz", "wz", "bz", "mmgjjggw", "zj", "yz" }, fly = { "wzbzmmgjjggwvjyvz", "wzbzmmgjjggwvjyv", "wz", "bz", "mmgjjggw", "vj", "yv" } },
  { text = "盗窃、抢夺、毁灭国家机关公文、证件、印章罪", comment = "〔第六章第一节 第280条〕", type = "crime", m_qp = "dqqdhmgjjggwzjyzz", m_fly = "dqqdhmgjjggwvjyvz", qp = { "dqqdhmgjjggwzjyzz", "dqqdhmgjjggwzjyz", "dq", "qd", "hmgjjggw", "zj", "yz" }, fly = { "dqqdhmgjjggwvjyvz", "dqqdhmgjjggwvjyv", "dq", "qd", "hmgjjggw", "vj", "yv" } },
  { text = "伪造公司、企业、事业单位、人民团体印章罪", comment = "〔第六章第一节 第280条〕", type = "crime", m_qp = "wzgsqysydwrmttyzz", m_fly = "wzgsqyuydwrmttyvz", qp = { "wzgsqysydwrmttyzz", "wzgsqysydwrmttyz", "wzgs", "qy", "sydw", "rmttyz" }, fly = { "wzgsqyuydwrmttyvz", "wzgsqyuydwrmttyv", "wzgs", "qy", "uydw", "rmttyv" } },
  { text = "伪造、变造、买卖身份证件罪", comment = "〔第六章第一节 第280条〕", type = "crime", m_qp = "wzbzmmsfzjz", m_fly = "wzbzmmufvjz", qp = { "wzbzmmsfzjz", "wzbzmmsfzj", "wz", "bz", "mmsfzj" }, fly = { "wzbzmmufvjz", "wzbzmmufvj", "wz", "bz", "mmufvj" } },
  { text = "使用虚假身份证件、盗用身份证件罪", comment = "〔第六章第一节 第280条之一〕", type = "crime", m_qp = "syxjsfzjdysfzjz", m_fly = "uyxjufvjdyufvjz", qp = { "syxjsfzjdysfzjz", "syxjsfzjdysfzj", "syxjsfzj", "dysfzj" }, fly = { "uyxjufvjdyufvjz", "uyxjufvjdyufvj", "uyxjufvj", "dyufvj" } },
  { text = "冒名顶替罪", comment = "〔第六章第一节 第280条之二〕", type = "crime", m_qp = "mmdtz", m_fly = "mmdtz", qp = { "mmdtz", "mmdt" }, fly = { "mmdtz", "mmdt" } },
  { text = "非法生产、买卖警用装备罪", comment = "〔第六章第一节 第281条〕", type = "crime", m_qp = "ffscmmjyzbz", m_fly = "ffuimmjyvbz", qp = { "ffscmmjyzbz", "ffscmmjyzb", "ffsc", "mmjyzb" }, fly = { "ffuimmjyvbz", "ffuimmjyvb", "ffui", "mmjyvb" } },
  { text = "非法获取国家秘密罪", comment = "〔第六章第一节 第282条〕", type = "crime", m_qp = "ffhqgjmmz", m_fly = "ffhqgjmmz", qp = { "ffhqgjmmz", "ffhqgjmm" }, fly = { "ffhqgjmmz", "ffhqgjmm" } },
  { text = "非法持有国家绝密、机密文件、资料、物品罪", comment = "〔第六章第一节 第282条〕", type = "crime", m_qp = "ffcygjjmjmwjzlwpz", m_fly = "ffiygjjmjmwjzlwpz", qp = { "ffcygjjmjmwjzlwpz", "ffcygjjmjmwjzlwp", "ffcygjjm", "jmwj", "zl", "wp" }, fly = { "ffiygjjmjmwjzlwpz", "ffiygjjmjmwjzlwp", "ffiygjjm", "jmwj", "zl", "wp" } },
  { text = "非法生产、销售专用间谍器材、窃听、窃照专用器材罪", comment = "〔第六章第一节 第283条〕", type = "crime", m_qp = "ffscxszyjdqcqtqzzyqcz", m_fly = "ffuixuvyjdqcqtqvvyqcz", qp = { "ffscxszyjdqcqtqzzyqcz", "ffscxszyjdqcqtqzzyqc", "ffsc", "xszyjdqc", "qt", "qzzyqc" }, fly = { "ffuixuvyjdqcqtqvvyqcz", "ffuixuvyjdqcqtqvvyqc", "ffui", "xuvyjdqc", "qt", "qvvyqc" } },
  { text = "非法使用窃听、窃照专用器材罪", comment = "〔第六章第一节 第284条〕", type = "crime", m_qp = "ffsyqtqzzyqcz", m_fly = "ffuyqtqvvyqcz", qp = { "ffsyqtqzzyqcz", "ffsyqtqzzyqc", "ffsyqt", "qzzyqc" }, fly = { "ffuyqtqvvyqcz", "ffuyqtqvvyqc", "ffuyqt", "qvvyqc" } },
  { text = "组织考试作弊罪", comment = "〔第六章第一节 第284条之一〕", type = "crime", m_qp = "zzkszbz", m_fly = "zvkuzbz", qp = { "zzkszbz", "zzkszb" }, fly = { "zvkuzbz", "zvkuzb" } },
  { text = "非法出售、提供试题、答案罪", comment = "〔第六章第一节 第284条之一〕", type = "crime", m_qp = "ffcstgstdaz", m_fly = "ffiutgutdaz", qp = { "ffcstgstdaz", "ffcstgstda", "ffcs", "tgst", "da" }, fly = { "ffiutgutdaz", "ffiutgutda", "ffiu", "tgut", "da" } },
  { text = "代替考试罪", comment = "〔第六章第一节 第284条之一〕", type = "crime", m_qp = "dtksz", m_fly = "dtkuz", qp = { "dtksz", "dtks" }, fly = { "dtkuz", "dtku" } },
  { text = "非法侵入计算机信息系统罪", comment = "〔第六章第一节 第285条〕", type = "crime", m_qp = "ffqrjsjxxxtz", m_fly = "ffqrjsjxxxtz", qp = { "ffqrjsjxxxtz", "ffqrjsjxxxt" }, fly = { "ffqrjsjxxxtz", "ffqrjsjxxxt" } },
  { text = "非法获取计算机信息系统数据、非法控制计算机信息系统罪", comment = "〔第六章第一节 第285条〕", type = "crime", m_qp = "ffhqjsjxxxtsjffkzjsjxxxtz", m_fly = "ffhqjsjxxxtujffkvjsjxxxtz", qp = { "ffhqjsjxxxtsjffkzjsjxxxtz", "ffhqjsjxxxtsjffkzjsjxxxt", "ffhqjsjxxxtsj", "ffkzjsjxxxt" }, fly = { "ffhqjsjxxxtujffkvjsjxxxtz", "ffhqjsjxxxtujffkvjsjxxxt", "ffhqjsjxxxtuj", "ffkvjsjxxxt" } },
  { text = "提供侵入、非法控制计算机信息系统程序、工具罪", comment = "〔第六章第一节 第285条〕", type = "crime", m_qp = "tgqrffkzjsjxxxtcxgjz", m_fly = "tgqrffkvjsjxxxtixgjz", qp = { "tgqrffkzjsjxxxtcxgjz", "tgqrffkzjsjxxxtcxgj", "tgqr", "ffkzjsjxxxtcx", "gj" }, fly = { "tgqrffkvjsjxxxtixgjz", "tgqrffkvjsjxxxtixgj", "tgqr", "ffkvjsjxxxtix", "gj" } },
  { text = "破坏计算机信息系统罪", comment = "〔第六章第一节 第286条〕", type = "crime", m_qp = "phjsjxxxtz", m_fly = "phjsjxxxtz", qp = { "phjsjxxxtz", "phjsjxxxt" }, fly = { "phjsjxxxtz", "phjsjxxxt" } },
  { text = "拒不履行信息网络安全管理义务罪", comment = "〔第六章第一节 第286条之一〕", type = "crime", m_qp = "jblxxxwlaqglywz", m_fly = "jblxxxwlaqglywz", qp = { "jblxxxwlaqglywz", "jblxxxwlaqglyw" }, fly = { "jblxxxwlaqglywz", "jblxxxwlaqglyw" } },
  { text = "非法利用信息网络罪", comment = "〔第六章第一节 第287条之一〕", type = "crime", m_qp = "fflyxxwlz", m_fly = "fflyxxwlz", qp = { "fflyxxwlz", "fflyxxwl" }, fly = { "fflyxxwlz", "fflyxxwl" } },
  { text = "帮助信息网络犯罪活动罪", comment = "〔第六章第一节 第287条之二〕", type = "crime", m_qp = "bzxxwlfzhdz", m_fly = "bvxxwlfzhdz", qp = { "bzxxwlfzhdz", "bzxxwlfzhd" }, fly = { "bvxxwlfzhdz", "bvxxwlfzhd" } },
  { text = "扰乱无线电通讯管理秩序罪", comment = "〔第六章第一节 第288条〕", type = "crime", m_qp = "rlwxdtxglzxz", m_fly = "rlwxdtxglvxz", qp = { "rlwxdtxglzxz", "rlwxdtxglzx" }, fly = { "rlwxdtxglvxz", "rlwxdtxglvx" } },
  { text = "聚众扰乱社会秩序罪", comment = "〔第六章第一节 第290条〕", type = "crime", m_qp = "jzrlshzxz", m_fly = "jvrluhvxz", qp = { "jzrlshzxz", "jzrlshzx" }, fly = { "jvrluhvxz", "jvrluhvx" } },
  { text = "聚众冲击国家机关罪", comment = "〔第六章第一节 第290条〕", type = "crime", m_qp = "jzcjgjjgz", m_fly = "jvijgjjgz", qp = { "jzcjgjjgz", "jzcjgjjg" }, fly = { "jvijgjjgz", "jvijgjjg" } },
  { text = "扰乱国家机关工作秩序罪", comment = "〔第六章第一节 第290条〕", type = "crime", m_qp = "rlgjjggzzxz", m_fly = "rlgjjggzvxz", qp = { "rlgjjggzzxz", "rlgjjggzzx" }, fly = { "rlgjjggzvxz", "rlgjjggzvx" } },
  { text = "组织、资助非法聚集罪", comment = "〔第六章第一节 第290条〕", type = "crime", m_qp = "zzzzffjjz", m_fly = "zvzvffjjz", qp = { "zzzzffjjz", "zzzzffjj", "zz", "zzffjj" }, fly = { "zvzvffjjz", "zvzvffjj", "zv", "zvffjj" } },
  { text = "聚众扰乱公共场所秩序、交通秩序罪", comment = "〔第六章第一节 第291条〕", type = "crime", m_qp = "jzrlggcszxjtzxz", m_fly = "jvrlggisvxjtvxz", qp = { "jzrlggcszxjtzxz", "jzrlggcszxjtzx", "jzrlggcszx", "jtzx" }, fly = { "jvrlggisvxjtvxz", "jvrlggisvxjtvx", "jvrlggisvx", "jtvx" } },
  { text = "投放虚假危险物质罪", comment = "〔第六章第一节 第291条之一〕", type = "crime", m_qp = "tfxjwxwzz", m_fly = "tfxjwxwvz", qp = { "tfxjwxwzz", "tfxjwxwz" }, fly = { "tfxjwxwvz", "tfxjwxwv" } },
  { text = "编造、故意传播虚假恐怖信息罪", comment = "〔第六章第一节 第291条之一〕", type = "crime", m_qp = "bzgycbxjkbxxz", m_fly = "bzgyibxjkbxxz", qp = { "bzgycbxjkbxxz", "bzgycbxjkbxx", "bz", "gycbxjkbxx" }, fly = { "bzgyibxjkbxxz", "bzgyibxjkbxx", "bz", "gyibxjkbxx" } },
  { text = "编造、故意传播虚假信息罪", comment = "〔第六章第一节 第291条之一〕", type = "crime", m_qp = "bzgycbxjxxz", m_fly = "bzgyibxjxxz", qp = { "bzgycbxjxxz", "bzgycbxjxx", "bz", "gycbxjxx" }, fly = { "bzgyibxjxxz", "bzgyibxjxx", "bz", "gyibxjxx" } },
  { text = "高空抛物罪", comment = "〔第六章第一节 第291条之二〕", type = "crime", m_qp = "gkpwz", m_fly = "gkpwz", qp = { "gkpwz", "gkpw" }, fly = { "gkpwz", "gkpw" } },
  { text = "聚众斗殴罪", comment = "〔第六章第一节 第292条〕", type = "crime", m_qp = "jzdoz", m_fly = "jvdoz", qp = { "jzdoz", "jzdo" }, fly = { "jvdoz", "jvdo" } },
  { text = "寻衅滋事罪", comment = "〔第六章第一节 第293条〕", type = "crime", m_qp = "xxzsz", m_fly = "xxzuz", qp = { "xxzsz", "xxzs" }, fly = { "xxzuz", "xxzu" } },
  { text = "催收非法债务罪", comment = "〔第六章第一节 第293条之一〕", type = "crime", m_qp = "csffzwz", m_fly = "cuffvwz", qp = { "csffzwz", "csffzw" }, fly = { "cuffvwz", "cuffvw" } },
  { text = "组织、领导、参加黑社会性质组织罪", comment = "〔第六章第一节 第294条〕", type = "crime", m_qp = "zzldcjhshxzzzz", m_fly = "zvldcjhuhxvzvz", qp = { "zzldcjhshxzzzz", "zzldcjhshxzzz", "zz", "ld", "cjhshxzzz" }, fly = { "zvldcjhuhxvzvz", "zvldcjhuhxvzv", "zv", "ld", "cjhuhxvzv" } },
  { text = "入境发展黑社会组织罪", comment = "〔第六章第一节 第294条〕", type = "crime", m_qp = "rjfzhshzzz", m_fly = "rjfvhuhzvz", qp = { "rjfzhshzzz", "rjfzhshzz" }, fly = { "rjfvhuhzvz", "rjfvhuhzv" } },
  { text = "包庇、纵容黑社会性质组织罪", comment = "〔第六章第一节 第294条〕", type = "crime", m_qp = "bbzrhshxzzzz", m_fly = "bbzrhuhxvzvz", qp = { "bbzrhshxzzzz", "bbzrhshxzzz", "bb", "zrhshxzzz" }, fly = { "bbzrhuhxvzvz", "bbzrhuhxvzv", "bb", "zrhuhxvzv" } },
  { text = "传授犯罪方法罪", comment = "〔第六章第一节 第295条〕", type = "crime", m_qp = "csfzffz", m_fly = "iufzffz", qp = { "csfzffz", "csfzff" }, fly = { "iufzffz", "iufzff" } },
  { text = "非法集会、游行、示威罪", comment = "〔第六章第一节 第296条〕", type = "crime", m_qp = "ffjhyxswz", m_fly = "ffjhyxuwz", qp = { "ffjhyxswz", "ffjhyxsw", "ffjh", "yx", "sw" }, fly = { "ffjhyxuwz", "ffjhyxuw", "ffjh", "yx", "uw" } },
  { text = "非法携带武器、管制刀具、爆炸物参加集会、游行、示威罪", comment = "〔第六章第一节 第297条〕", type = "crime", m_qp = "ffxdwqgzdjbzwcjjhyxswz", m_fly = "ffxdwqgvdjbvwcjjhyxuwz", qp = { "ffxdwqgzdjbzwcjjhyxswz", "ffxdwqgzdjbzwcjjhyxsw", "ffxdwq", "gzdj", "bzwcjjh", "yx", "sw" }, fly = { "ffxdwqgvdjbvwcjjhyxuwz", "ffxdwqgvdjbvwcjjhyxuw", "ffxdwq", "gvdj", "bvwcjjh", "yx", "uw" } },
  { text = "破坏集会、游行、示威罪", comment = "〔第六章第一节 第298条〕", type = "crime", m_qp = "phjhyxswz", m_fly = "phjhyxuwz", qp = { "phjhyxswz", "phjhyxsw", "phjh", "yx", "sw" }, fly = { "phjhyxuwz", "phjhyxuw", "phjh", "yx", "uw" } },
  { text = "侮辱国旗、国徽、国歌罪", comment = "〔第六章第一节 第299条〕", type = "crime", m_qp = "wrgqghggz", m_fly = "wrgqghggz", qp = { "wrgqghggz", "wrgqghgg", "wrgq", "gh", "gg" }, fly = { "wrgqghggz", "wrgqghgg", "wrgq", "gh", "gg" } },
  { text = "侵害英雄烈士名誉、荣誉罪", comment = "〔第六章第一节 第299条之一〕", type = "crime", m_qp = "qhyxlsmyryz", m_fly = "qhyxlumyryz", qp = { "qhyxlsmyryz", "qhyxlsmyry", "qhyxlsmy", "ry" }, fly = { "qhyxlumyryz", "qhyxlumyry", "qhyxlumy", "ry" } },
  { text = "组织、利用会道门、邪教组织、利用迷信破坏法律实施罪", comment = "〔第六章第一节 第300条〕", type = "crime", m_qp = "zzlyhdmxjzzlymxphflssz", m_fly = "zvlyhdmxjzvlymxphfluuz", qp = { "zzlyhdmxjzzlymxphflssz", "zzlyhdmxjzzlymxphflss", "zz", "lyhdm", "xjzz", "lymxphflss" }, fly = { "zvlyhdmxjzvlymxphfluuz", "zvlyhdmxjzvlymxphfluu", "zv", "lyhdm", "xjzv", "lymxphfluu" } },
  { text = "组织、利用会道门、邪教组织、利用迷信致人重伤、死亡罪", comment = "〔第六章第一节 第300条〕", type = "crime", m_qp = "zzlyhdmxjzzlymxzrzsswz", m_fly = "zvlyhdmxjzvlymxvrvuswz", qp = { "zzlyhdmxjzzlymxzrzsswz", "zzlyhdmxjzzlymxzrzssw", "zz", "lyhdm", "xjzz", "lymxzrzs", "sw" }, fly = { "zvlyhdmxjzvlymxvrvuswz", "zvlyhdmxjzvlymxvrvusw", "zv", "lyhdm", "xjzv", "lymxvrvu", "sw" } },
  { text = "聚众淫乱罪", comment = "〔第六章第一节 第301条〕", type = "crime", m_qp = "jzylz", m_fly = "jvylz", qp = { "jzylz", "jzyl" }, fly = { "jvylz", "jvyl" } },
  { text = "引诱未成年人聚众淫乱罪", comment = "〔第六章第一节 第301条〕", type = "crime", m_qp = "yywcnrjzylz", m_fly = "yywinrjvylz", qp = { "yywcnrjzylz", "yywcnrjzyl" }, fly = { "yywinrjvylz", "yywinrjvyl" } },
  { text = "盗窃、侮辱、故意毁坏尸体、尸骨、骨灰罪", comment = "〔第六章第一节 第302条〕", type = "crime", m_qp = "dqwrgyhhstsgghz", m_fly = "dqwrgyhhutugghz", qp = { "dqwrgyhhstsgghz", "dqwrgyhhstsggh", "dq", "wr", "gyhhst", "sg", "gh" }, fly = { "dqwrgyhhutugghz", "dqwrgyhhutuggh", "dq", "wr", "gyhhut", "ug", "gh" } },
  { text = "赌博罪", comment = "〔第六章第一节 第303条〕", type = "crime", m_qp = "dbz", m_fly = "dbz", qp = { "dbz", "db" }, fly = { "dbz", "db" } },
  { text = "开设赌场罪", comment = "〔第六章第一节 第303条〕", type = "crime", m_qp = "ksdcz", m_fly = "kudiz", qp = { "ksdcz", "ksdc" }, fly = { "kudiz", "kudi" } },
  { text = "组织参与国（境）外赌博罪", comment = "〔第六章第一节 第303条〕", type = "crime", m_qp = "zzcygjwdbz", m_fly = "zvcygjwdbz", qp = { "zzcygjwdbz", "zzcygjwdb" }, fly = { "zvcygjwdbz", "zvcygjwdb" } },
  { text = "故意延误投递邮件罪", comment = "〔第六章第一节 第304条〕", type = "crime", m_qp = "gyywtdyjz", m_fly = "gyywtdyjz", qp = { "gyywtdyjz", "gyywtdyj" }, fly = { "gyywtdyjz", "gyywtdyj" } },
  { text = "伪证罪", comment = "〔第六章第二节 第305条〕", type = "crime", m_qp = "wzz", m_fly = "wvz", qp = { "wzz", "wz" }, fly = { "wvz", "wv" } },
  { text = "辩护人、诉讼代理人毁灭证据、伪造证据、妨害作证罪", comment = "〔第六章第二节 第306条〕", type = "crime", m_qp = "bhrssdlrhmzjwzzjfhzzz", m_fly = "bhrssdlrhmvjwzvjfhzvz", qp = { "bhrssdlrhmzjwzzjfhzzz", "bhrssdlrhmzjwzzjfhzz", "bhr", "ssdlrhmzj", "wzzj", "fhzz" }, fly = { "bhrssdlrhmvjwzvjfhzvz", "bhrssdlrhmvjwzvjfhzv", "bhr", "ssdlrhmvj", "wzvj", "fhzv" } },
  { text = "妨害作证罪", comment = "〔第六章第二节 第307条〕", type = "crime", m_qp = "fhzzz", m_fly = "fhzvz", qp = { "fhzzz", "fhzz" }, fly = { "fhzvz", "fhzv" } },
  { text = "帮助毁灭、伪造证据罪", comment = "〔第六章第二节 第307条〕", type = "crime", m_qp = "bzhmwzzjz", m_fly = "bvhmwzvjz", qp = { "bzhmwzzjz", "bzhmwzzj", "bzhm", "wzzj" }, fly = { "bvhmwzvjz", "bvhmwzvj", "bvhm", "wzvj" } },
  { text = "虚假诉讼罪", comment = "〔第六章第二节 第307条之一〕", type = "crime", m_qp = "xjssz", m_fly = "xjssz", qp = { "xjssz", "xjss" }, fly = { "xjssz", "xjss" } },
  { text = "打击报复证人罪", comment = "〔第六章第二节 第308条〕", type = "crime", m_qp = "djbfzrz", m_fly = "djbfvrz", qp = { "djbfzrz", "djbfzr" }, fly = { "djbfvrz", "djbfvr" } },
  { text = "泄露不应公开的案件信息罪", comment = "〔第六章第二节 第308条之一〕", type = "crime", m_qp = "xlbygkdajxxz", m_fly = "xlbygkdajxxz", qp = { "xlbygkdajxxz", "xlbygkdajxx" }, fly = { "xlbygkdajxxz", "xlbygkdajxx" } },
  { text = "披露、报道不应公开的案件信息罪", comment = "〔第六章第二节 第308条之一〕", type = "crime", m_qp = "plbdbygkdajxxz", m_fly = "plbdbygkdajxxz", qp = { "plbdbygkdajxxz", "plbdbygkdajxx", "pl", "bdbygkdajxx" }, fly = { "plbdbygkdajxxz", "plbdbygkdajxx", "pl", "bdbygkdajxx" } },
  { text = "扰乱法庭秩序罪", comment = "〔第六章第二节 第309条〕", type = "crime", m_qp = "rlftzxz", m_fly = "rlftvxz", qp = { "rlftzxz", "rlftzx" }, fly = { "rlftvxz", "rlftvx" } },
  { text = "窝藏、包庇罪", comment = "〔第六章第二节 第310条〕", type = "crime", m_qp = "wcbbz", m_fly = "wcbbz", qp = { "wcbbz", "wcbb", "wc", "bb" }, fly = { "wcbbz", "wcbb", "wc", "bb" } },
  { text = "拒绝提供间谍犯罪、恐怖主义犯罪、极端主义犯罪证据罪", comment = "〔第六章第二节 第311条〕", type = "crime", m_qp = "jjtgjdfzkbzyfzjdzyfzzjz", m_fly = "jjtgjdfzkbvyfzjdvyfzvjz", qp = { "jjtgjdfzkbzyfzjdzyfzzjz", "jjtgjdfzkbzyfzjdzyfzzj", "jjtgjdf", "kbzyf", "jdzyfzj" }, fly = { "jjtgjdfzkbvyfzjdvyfzvjz", "jjtgjdfzkbvyfzjdvyfzvj", "jjtgjdf", "kbvyf", "jdvyfvj" } },
  { text = "掩饰、隐瞒犯罪所得、犯罪所得收益罪", comment = "〔第六章第二节 第312条〕", type = "crime", m_qp = "ysymfzsdfzsdsyz", m_fly = "yuymfzsdfzsduyz", qp = { "ysymfzsdfzsdsyz", "ysymfzsdfzsdsy", "ys", "ymfsd", "fsdsy" }, fly = { "yuymfzsdfzsduyz", "yuymfzsdfzsduy", "yu", "ymfsd", "fsduy" } },
  { text = "拒不执行判决、裁定罪", comment = "〔第六章第二节 第313条〕", type = "crime", m_qp = "jbzxpjcdz", m_fly = "jbvxpjcdz", qp = { "jbzxpjcdz", "jbzxpjcd", "jbzxpj", "cd" }, fly = { "jbvxpjcdz", "jbvxpjcd", "jbvxpj", "cd" } },
  { text = "非法处置查封、扣押、冻结的财产罪", comment = "〔第六章第二节 第314条〕", type = "crime", m_qp = "ffczcfkydjdccz", m_fly = "ffivifkydjdciz", qp = { "ffczcfkydjdccz", "ffczcfkydjdcc", "ffczcf", "ky", "djdcc" }, fly = { "ffivifkydjdciz", "ffivifkydjdci", "ffivif", "ky", "djdci" } },
  { text = "破坏监管秩序罪", comment = "〔第六章第二节 第315条〕", type = "crime", m_qp = "phjgzxz", m_fly = "phjgvxz", qp = { "phjgzxz", "phjgzx" }, fly = { "phjgvxz", "phjgvx" } },
  { text = "脱逃罪", comment = "〔第六章第二节 第316条〕", type = "crime", m_qp = "ttz", m_fly = "ttz", qp = { "ttz", "tt" }, fly = { "ttz", "tt" } },
  { text = "劫夺被押解人员罪", comment = "〔第六章第二节 第316条〕", type = "crime", m_qp = "jdbyjryz", m_fly = "jdbyjryz", qp = { "jdbyjryz", "jdbyjry" }, fly = { "jdbyjryz", "jdbyjry" } },
  { text = "组织越狱罪", comment = "〔第六章第二节 第317条〕", type = "crime", m_qp = "zzyyz", m_fly = "zvyyz", qp = { "zzyyz", "zzyy" }, fly = { "zvyyz", "zvyy" } },
  { text = "暴动越狱罪", comment = "〔第六章第二节 第317条〕", type = "crime", m_qp = "bdyyz", m_fly = "bdyyz", qp = { "bdyyz", "bdyy" }, fly = { "bdyyz", "bdyy" } },
  { text = "聚众持械劫狱罪", comment = "〔第六章第二节 第317条〕", type = "crime", m_qp = "jzcxjyz", m_fly = "jvixjyz", qp = { "jzcxjyz", "jzcxjy" }, fly = { "jvixjyz", "jvixjy" } },
  { text = "组织他人偷越国（边）境罪", comment = "〔第六章第三节 第318条〕", type = "crime", m_qp = "zztrtygbjz", m_fly = "zvtrtygbjz", qp = { "zztrtygbjz", "zztrtygbj" }, fly = { "zvtrtygbjz", "zvtrtygbj" } },
  { text = "骗取出境证件罪", comment = "〔第六章第三节 第319条〕", type = "crime", m_qp = "pqcjzjz", m_fly = "pqijvjz", qp = { "pqcjzjz", "pqcjzj" }, fly = { "pqijvjz", "pqijvj" } },
  { text = "提供伪造、变造的出入境证件罪", comment = "〔第六章第三节 第320条〕", type = "crime", m_qp = "tgwzbzdcrjzjz", m_fly = "tgwzbzdirjvjz", qp = { "tgwzbzdcrjzjz", "tgwzbzdcrjzj", "tgwz", "bzdcrjzj" }, fly = { "tgwzbzdirjvjz", "tgwzbzdirjvj", "tgwz", "bzdirjvj" } },
  { text = "出售出入境证件罪", comment = "〔第六章第三节 第320条〕", type = "crime", m_qp = "cscrjzjz", m_fly = "iuirjvjz", qp = { "cscrjzjz", "cscrjzj" }, fly = { "iuirjvjz", "iuirjvj" } },
  { text = "运送他人偷越国（边）境罪", comment = "〔第六章第三节 第321条〕", type = "crime", m_qp = "ystrtygbjz", m_fly = "ystrtygbjz", qp = { "ystrtygbjz", "ystrtygbj" }, fly = { "ystrtygbjz", "ystrtygbj" } },
  { text = "偷越国（边）境罪", comment = "〔第六章第三节 第322条〕", type = "crime", m_qp = "tygbjz", m_fly = "tygbjz", qp = { "tygbjz", "tygbj" }, fly = { "tygbjz", "tygbj" } },
  { text = "破坏界碑、界桩罪", comment = "〔第六章第三节 第323条〕", type = "crime", m_qp = "phjbjzz", m_fly = "phjbjvz", qp = { "phjbjzz", "phjbjz", "phjb", "jz" }, fly = { "phjbjvz", "phjbjv", "phjb", "jv" } },
  { text = "破坏永久性测量标志罪", comment = "〔第六章第三节 第323条〕", type = "crime", m_qp = "phyjxclbzz", m_fly = "phyjxclbvz", qp = { "phyjxclbzz", "phyjxclbz" }, fly = { "phyjxclbvz", "phyjxclbv" } },
  { text = "故意损毁文物罪", comment = "〔第六章第四节 第324条〕", type = "crime", m_qp = "gyshwwz", m_fly = "gyshwwz", qp = { "gyshwwz", "gyshww" }, fly = { "gyshwwz", "gyshww" } },
  { text = "故意损毁名胜古迹罪", comment = "〔第六章第四节 第324条〕", type = "crime", m_qp = "gyshmsgjz", m_fly = "gyshmugjz", qp = { "gyshmsgjz", "gyshmsgj" }, fly = { "gyshmugjz", "gyshmugj" } },
  { text = "过失损毁文物罪", comment = "〔第六章第四节 第324条〕", type = "crime", m_qp = "gsshwwz", m_fly = "gushwwz", qp = { "gsshwwz", "gsshww" }, fly = { "gushwwz", "gushww" } },
  { text = "非法向外国人出售、赠送珍贵文物罪", comment = "〔第六章第四节 第325条〕", type = "crime", m_qp = "ffxwgrcszszgwwz", m_fly = "ffxwgriuzsvgwwz", qp = { "ffxwgrcszszgwwz", "ffxwgrcszszgww", "ffxwgrcs", "zszgww" }, fly = { "ffxwgriuzsvgwwz", "ffxwgriuzsvgww", "ffxwgriu", "zsvgww" } },
  { text = "倒卖文物罪", comment = "〔第六章第四节 第326条〕", type = "crime", m_qp = "dmwwz", m_fly = "dmwwz", qp = { "dmwwz", "dmww" }, fly = { "dmwwz", "dmww" } },
  { text = "非法出售、私赠文物藏品罪", comment = "〔第六章第四节 第327条〕", type = "crime", m_qp = "ffcsszwwcpz", m_fly = "ffiuszwwcpz", qp = { "ffcsszwwcpz", "ffcsszwwcp", "ffcs", "szwwcp" }, fly = { "ffiuszwwcpz", "ffiuszwwcp", "ffiu", "szwwcp" } },
  { text = "盗掘古文化遗址、古墓葬罪", comment = "〔第六章第四节 第328条〕", type = "crime", m_qp = "djgwhyzgmzz", m_fly = "djgwhyvgmzz", qp = { "djgwhyzgmzz", "djgwhyzgmz", "djgwhyz", "gmz" }, fly = { "djgwhyvgmzz", "djgwhyvgmz", "djgwhyv", "gmz" } },
  { text = "盗掘古人类化石、古脊椎动物化石罪", comment = "〔第六章第四节 第328条〕", type = "crime", m_qp = "djgrlhsgjzdwhsz", m_fly = "djgrlhugjvdwhuz", qp = { "djgrlhsgjzdwhsz", "djgrlhsgjzdwhs", "djgrlhs", "gjzdwhs" }, fly = { "djgrlhugjvdwhuz", "djgrlhugjvdwhu", "djgrlhu", "gjvdwhu" } },
  { text = "抢夺、窃取国有档案罪", comment = "〔第六章第四节 第329条〕", type = "crime", m_qp = "qdqqgydaz", m_fly = "qdqqgydaz", qp = { "qdqqgydaz", "qdqqgyda", "qd", "qqgyda" }, fly = { "qdqqgydaz", "qdqqgyda", "qd", "qqgyda" } },
  { text = "擅自出卖、转让国有档案罪", comment = "〔第六章第四节 第329条〕", type = "crime", m_qp = "szcmzrgydaz", m_fly = "uzimvrgydaz", qp = { "szcmzrgydaz", "szcmzrgyda", "szcm", "zrgyda" }, fly = { "uzimvrgydaz", "uzimvrgyda", "uzim", "vrgyda" } },
  { text = "妨害传染病防治罪", comment = "〔第六章第五节 第330条〕", type = "crime", m_qp = "fhcrbfzz", m_fly = "fhirbfvz", qp = { "fhcrbfzz", "fhcrbfz" }, fly = { "fhirbfvz", "fhirbfv" } },
  { text = "传染病菌种、毒种扩散罪", comment = "〔第六章第五节 第331条〕", type = "crime", m_qp = "crbjzdzksz", m_fly = "irbjvdvksz", qp = { "crbjzdzksz", "crbjzdzks", "crbjz", "dzks" }, fly = { "irbjvdvksz", "irbjvdvks", "irbjv", "dvks" } },
  { text = "妨害国境卫生检疫罪", comment = "〔第六章第五节 第332条〕", type = "crime", m_qp = "fhgjwsjyz", m_fly = "fhgjwujyz", qp = { "fhgjwsjyz", "fhgjwsjy" }, fly = { "fhgjwujyz", "fhgjwujy" } },
  { text = "非法组织卖血罪", comment = "〔第六章第五节 第333条〕", type = "crime", m_qp = "ffzzmxz", m_fly = "ffzvmxz", qp = { "ffzzmxz", "ffzzmx" }, fly = { "ffzvmxz", "ffzvmx" } },
  { text = "强迫卖血罪", comment = "〔第六章第五节 第333条〕", type = "crime", m_qp = "qpmxz", m_fly = "qpmxz", qp = { "qpmxz", "qpmx" }, fly = { "qpmxz", "qpmx" } },
  { text = "非法采集、供应血液、制作、供应血液制品罪", comment = "〔第六章第五节 第334条〕", type = "crime", m_qp = "ffcjgyxyzzgyxyzpz", m_fly = "ffcjgyxyvzgyxyvpz", qp = { "ffcjgyxyzzgyxyzpz", "ffcjgyxyzzgyxyzp", "ffcj", "gyxy", "zz", "gyxyzp" }, fly = { "ffcjgyxyvzgyxyvpz", "ffcjgyxyvzgyxyvp", "ffcj", "gyxy", "vz", "gyxyvp" } },
  { text = "采集、供应血液、制作、供应血液制品事故罪", comment = "〔第六章第五节 第334条〕", type = "crime", m_qp = "cjgyxyzzgyxyzpsgz", m_fly = "cjgyxyvzgyxyvpugz", qp = { "cjgyxyzzgyxyzpsgz", "cjgyxyzzgyxyzpsg", "cj", "gyxy", "zz", "gyxyzpsg" }, fly = { "cjgyxyvzgyxyvpugz", "cjgyxyvzgyxyvpug", "cj", "gyxy", "vz", "gyxyvpug" } },
  { text = "非法采集人类遗传资源、走私人类遗传资源材料罪", comment = "〔第六章第五节 第334条之一〕", type = "crime", m_qp = "ffcjrlyczyzsrlyczyclz", m_fly = "ffcjrlyizyzsrlyizyclz", qp = { "ffcjrlyczyzsrlyczyclz", "ffcjrlyczyzsrlyczycl", "ffcjrlyczy", "zsrlyczycl" }, fly = { "ffcjrlyizyzsrlyizyclz", "ffcjrlyizyzsrlyizycl", "ffcjrlyizy", "zsrlyizycl" } },
  { text = "医疗事故罪", comment = "〔第六章第五节 第335条〕", type = "crime", m_qp = "ylsgz", m_fly = "ylugz", qp = { "ylsgz", "ylsg" }, fly = { "ylugz", "ylug" } },
  { text = "非法行医罪", comment = "〔第六章第五节 第336条〕", type = "crime", m_qp = "ffxyz", m_fly = "ffxyz", qp = { "ffxyz", "ffxy" }, fly = { "ffxyz", "ffxy" } },
  { text = "非法进行节育手术罪", comment = "〔第六章第五节 第336条〕", type = "crime", m_qp = "ffjxjyssz", m_fly = "ffjxjyuuz", qp = { "ffjxjyssz", "ffjxjyss" }, fly = { "ffjxjyuuz", "ffjxjyuu" } },
  { text = "非法植入基因编辑、克隆胚胎罪", comment = "〔第六章第五节 第336条之一〕", type = "crime", m_qp = "ffzrjybjklptz", m_fly = "ffvrjybjklptz", qp = { "ffzrjybjklptz", "ffzrjybjklpt", "ffzrjybj", "klpt" }, fly = { "ffvrjybjklptz", "ffvrjybjklpt", "ffvrjybj", "klpt" } },
  { text = "妨害动植物防疫、检疫罪", comment = "〔第六章第五节 第337条〕", type = "crime", m_qp = "fhdzwfyjyz", m_fly = "fhdvwfyjyz", qp = { "fhdzwfyjyz", "fhdzwfyjy", "fhdzwfy", "jy" }, fly = { "fhdvwfyjyz", "fhdvwfyjy", "fhdvwfy", "jy" } },
  { text = "污染环境罪", comment = "〔第六章第六节 第338条〕", type = "crime", m_qp = "wrhjz", m_fly = "wrhjz", qp = { "wrhjz", "wrhj" }, fly = { "wrhjz", "wrhj" } },
  { text = "非法处置进口的固体废物罪", comment = "〔第六章第六节 第339条〕", type = "crime", m_qp = "ffczjkdgtfwz", m_fly = "ffivjkdgtfwz", qp = { "ffczjkdgtfwz", "ffczjkdgtfw" }, fly = { "ffivjkdgtfwz", "ffivjkdgtfw" } },
  { text = "擅自进口固体废物罪", comment = "〔第六章第六节 第339条〕", type = "crime", m_qp = "szjkgtfwz", m_fly = "uzjkgtfwz", qp = { "szjkgtfwz", "szjkgtfw" }, fly = { "uzjkgtfwz", "uzjkgtfw" } },
  { text = "非法捕捞水产品罪", comment = "〔第六章第六节 第340条〕", type = "crime", m_qp = "ffblscpz", m_fly = "ffbluipz", qp = { "ffblscpz", "ffblscp" }, fly = { "ffbluipz", "ffbluip" } },
  { text = "危害珍贵、濒危野生动物罪", comment = "〔第六章第六节 第341条〕", type = "crime", m_qp = "whzgbwysdwz", m_fly = "whvgbwyudwz", qp = { "whzgbwysdwz", "whzgbwysdw", "whzg", "bwysdw" }, fly = { "whvgbwyudwz", "whvgbwyudw", "whvg", "bwyudw" } },
  { text = "非法狩猎罪", comment = "〔第六章第六节 第341条〕", type = "crime", m_qp = "ffslz", m_fly = "ffulz", qp = { "ffslz", "ffsl" }, fly = { "ffulz", "fful" } },
  { text = "非法猎捕、收购、运输、出售陆生野生动物罪", comment = "〔第六章第六节 第341条〕", type = "crime", m_qp = "fflbsgyscslsysdwz", m_fly = "fflbugyuiuluyudwz", qp = { "fflbsgyscslsysdwz", "fflbsgyscslsysdw", "fflb", "sg", "ys", "cslsysdw" }, fly = { "fflbugyuiuluyudwz", "fflbugyuiuluyudw", "fflb", "ug", "yu", "iuluyudw" } },
  { text = "非法占用农用地罪", comment = "〔第六章第六节 第342条〕", type = "crime", m_qp = "ffzynydz", m_fly = "ffvynydz", qp = { "ffzynydz", "ffzynyd" }, fly = { "ffvynydz", "ffvynyd" } },
  { text = "破坏自然保护地罪", comment = "〔第六章第六节 第342条之一〕", type = "crime", m_qp = "phzrbhdz", m_fly = "phzrbhdz", qp = { "phzrbhdz", "phzrbhd" }, fly = { "phzrbhdz", "phzrbhd" } },
  { text = "非法采矿罪", comment = "〔第六章第六节 第343条〕", type = "crime", m_qp = "ffckz", m_fly = "ffckz", qp = { "ffckz", "ffck" }, fly = { "ffckz", "ffck" } },
  { text = "破坏性采矿罪", comment = "〔第六章第六节 第343条〕", type = "crime", m_qp = "phxckz", m_fly = "phxckz", qp = { "phxckz", "phxck" }, fly = { "phxckz", "phxck" } },
  { text = "危害国家重点保护植物罪", comment = "〔第六章第六节 第344条〕", type = "crime", m_qp = "whgjzdbhzwz", m_fly = "whgjvdbhvwz", qp = { "whgjzdbhzwz", "whgjzdbhzw" }, fly = { "whgjvdbhvwz", "whgjvdbhvw" } },
  { text = "非法引进、释放、丢弃外来入侵物种罪", comment = "〔第六章第六节 第344条之一〕", type = "crime", m_qp = "ffyjsfdqwlrqwzz", m_fly = "ffyjufdqwlrqwvz", qp = { "ffyjsfdqwlrqwzz", "ffyjsfdqwlrqwz", "ffyj", "sf", "dqwlrqwz" }, fly = { "ffyjufdqwlrqwvz", "ffyjufdqwlrqwv", "ffyj", "uf", "dqwlrqwv" } },
  { text = "盗伐林木罪", comment = "〔第六章第六节 第345条〕", type = "crime", m_qp = "dflmz", m_fly = "dflmz", qp = { "dflmz", "dflm" }, fly = { "dflmz", "dflm" } },
  { text = "滥伐林木罪", comment = "〔第六章第六节 第345条〕", type = "crime", m_qp = "lflmz", m_fly = "lflmz", qp = { "lflmz", "lflm" }, fly = { "lflmz", "lflm" } },
  { text = "非法收购、运输盗伐、滥伐的林木罪", comment = "〔第六章第六节 第345条〕", type = "crime", m_qp = "ffsgysdflfdlmz", m_fly = "ffugyudflfdlmz", qp = { "ffsgysdflfdlmz", "ffsgysdflfdlm", "ffsg", "ysdf", "lfdlm" }, fly = { "ffugyudflfdlmz", "ffugyudflfdlm", "ffug", "yudf", "lfdlm" } },
  { text = "非法持有毒品罪", comment = "〔第六章第七节 第348条〕", type = "crime", m_qp = "ffcydpz", m_fly = "ffiydpz", qp = { "ffcydpz", "ffcydp" }, fly = { "ffiydpz", "ffiydp" } },
  { text = "包庇毒品犯罪分子罪", comment = "〔第六章第七节 第349条〕", type = "crime", m_qp = "bbdpfzfzz", m_fly = "bbdpfzfzz", qp = { "bbdpfzfzz", "bbdpfzfz" }, fly = { "bbdpfzfzz", "bbdpfzfz" } },
  { text = "窝藏、转移、隐瞒毒品、毒赃罪", comment = "〔第六章第七节 第349条〕", type = "crime", m_qp = "wczyymdpdzz", m_fly = "wcvyymdpdzz", qp = { "wczyymdpdzz", "wczyymdpdz", "wc", "zy", "ymdp", "dz" }, fly = { "wcvyymdpdzz", "wcvyymdpdz", "wc", "vy", "ymdp", "dz" } },
  { text = "非法生产、买卖、运输制毒物品、走私制毒物品罪", comment = "〔第六章第七节 第350条〕", type = "crime", m_qp = "ffscmmyszdwpzszdwpz", m_fly = "ffuimmyuvdwpzsvdwpz", qp = { "ffscmmyszdwpzszdwpz", "ffscmmyszdwpzszdwp", "ffsc", "mm", "yszdwp", "zszdwp" }, fly = { "ffuimmyuvdwpzsvdwpz", "ffuimmyuvdwpzsvdwp", "ffui", "mm", "yuvdwp", "zsvdwp" } },
  { text = "非法种植毒品原植物罪", comment = "〔第六章第七节 第351条〕", type = "crime", m_qp = "ffzzdpyzwz", m_fly = "ffvvdpyvwz", qp = { "ffzzdpyzwz", "ffzzdpyzw" }, fly = { "ffvvdpyvwz", "ffvvdpyvw" } },
  { text = "非法买卖、运输、携带、持有毒品原植物种子、幼苗罪", comment = "〔第六章第七节 第352条〕", type = "crime", m_qp = "ffmmysxdcydpyzwzzymz", m_fly = "ffmmyuxdiydpyvwvzymz", qp = { "ffmmysxdcydpyzwzzymz", "ffmmysxdcydpyzwzzym", "ffmm", "ys", "xd", "cydpyzwzz", "ym" }, fly = { "ffmmyuxdiydpyvwvzymz", "ffmmyuxdiydpyvwvzym", "ffmm", "yu", "xd", "iydpyvwvz", "ym" } },
  { text = "引诱、教唆、欺骗他人吸毒罪", comment = "〔第六章第七节 第353条〕", type = "crime", m_qp = "yyjsqptrxdz", m_fly = "yyjsqptrxdz", qp = { "yyjsqptrxdz", "yyjsqptrxd", "yy", "js", "qptrxd" }, fly = { "yyjsqptrxdz", "yyjsqptrxd", "yy", "js", "qptrxd" } },
  { text = "强迫他人吸毒罪", comment = "〔第六章第七节 第353条〕", type = "crime", m_qp = "qptrxdz", m_fly = "qptrxdz", qp = { "qptrxdz", "qptrxd" }, fly = { "qptrxdz", "qptrxd" } },
  { text = "容留他人吸毒罪", comment = "〔第六章第七节 第354条〕", type = "crime", m_qp = "rltrxdz", m_fly = "rltrxdz", qp = { "rltrxdz", "rltrxd" }, fly = { "rltrxdz", "rltrxd" } },
  { text = "非法提供麻醉药品、精神药品罪", comment = "〔第六章第七节 第355条〕", type = "crime", m_qp = "fftgmzypjsypz", m_fly = "fftgmzypjuypz", qp = { "fftgmzypjsypz", "fftgmzypjsyp", "fftgmzyp", "jsyp" }, fly = { "fftgmzypjuypz", "fftgmzypjuyp", "fftgmzyp", "juyp" } },
  { text = "妨害兴奋剂管理罪", comment = "〔第六章第七节 第355条之一〕", type = "crime", m_qp = "fhxfjglz", m_fly = "fhxfjglz", qp = { "fhxfjglz", "fhxfjgl" }, fly = { "fhxfjglz", "fhxfjgl" } },
  { text = "组织卖淫罪", comment = "〔第六章第八节 第358条〕", type = "crime", m_qp = "zzmyz", m_fly = "zvmyz", qp = { "zzmyz", "zzmy" }, fly = { "zvmyz", "zvmy" } },
  { text = "强迫卖淫罪", comment = "〔第六章第八节 第358条〕", type = "crime", m_qp = "qpmyz", m_fly = "qpmyz", qp = { "qpmyz", "qpmy" }, fly = { "qpmyz", "qpmy" } },
  { text = "协助组织卖淫罪", comment = "〔第六章第八节 第358条〕", type = "crime", m_qp = "xzzzmyz", m_fly = "xvzvmyz", qp = { "xzzzmyz", "xzzzmy" }, fly = { "xvzvmyz", "xvzvmy" } },
  { text = "引诱、容留、介绍卖淫罪", comment = "〔第六章第八节 第359条〕", type = "crime", m_qp = "yyrljsmyz", m_fly = "yyrljumyz", qp = { "yyrljsmyz", "yyrljsmy", "yy", "rl", "jsmy" }, fly = { "yyrljumyz", "yyrljumy", "yy", "rl", "jumy" } },
  { text = "引诱幼女卖淫罪", comment = "〔第六章第八节 第359条〕", type = "crime", m_qp = "yyynmyz", m_fly = "yyynmyz", qp = { "yyynmyz", "yyynmy" }, fly = { "yyynmyz", "yyynmy" } },
  { text = "传播性病罪", comment = "〔第六章第八节 第360条〕", type = "crime", m_qp = "cbxbz", m_fly = "ibxbz", qp = { "cbxbz", "cbxb" }, fly = { "ibxbz", "ibxb" } },
  { text = "包庇罪", comment = "〔第六章第八节 第362条〕", type = "crime", m_qp = "bbz", m_fly = "bbz", qp = { "bbz", "bb" }, fly = { "bbz", "bb" } },
  { text = "制作、复制、出版、贩卖、传播淫秽物品牟利罪", comment = "〔第六章第九节 第363条〕", type = "crime", m_qp = "zzfzcbfmcbyhwpmlz", m_fly = "vzfvibfmibyhwpmlz", qp = { "zzfzcbfmcbyhwpmlz", "zzfzcbfmcbyhwpml", "zz", "fz", "cb", "fm", "cbyhwpml" }, fly = { "vzfvibfmibyhwpmlz", "vzfvibfmibyhwpml", "vz", "fv", "ib", "fm", "ibyhwpml" } },
  { text = "为他人提供书号出版淫秽书刊罪", comment = "〔第六章第九节 第363条〕", type = "crime", m_qp = "wtrtgshcbyhskz", m_fly = "wtrtguhibyhukz", qp = { "wtrtgshcbyhskz", "wtrtgshcbyhsk" }, fly = { "wtrtguhibyhukz", "wtrtguhibyhuk" } },
  { text = "传播淫秽物品罪", comment = "〔第六章第九节 第364条〕", type = "crime", m_qp = "cbyhwpz", m_fly = "ibyhwpz", qp = { "cbyhwpz", "cbyhwp" }, fly = { "ibyhwpz", "ibyhwp" } },
  { text = "组织播放淫秽音像制品罪", comment = "〔第六章第九节 第364条〕", type = "crime", m_qp = "zzbfyhyxzpz", m_fly = "zvbfyhyxvpz", qp = { "zzbfyhyxzpz", "zzbfyhyxzp" }, fly = { "zvbfyhyxvpz", "zvbfyhyxvp" } },
  { text = "组织淫秽表演罪", comment = "〔第六章第九节 第365条〕", type = "crime", m_qp = "zzyhbyz", m_fly = "zvyhbyz", qp = { "zzyhbyz", "zzyhby" }, fly = { "zvyhbyz", "zvyhby" } },
  { text = "阻碍军人执行职务罪", comment = "〔第七章 第368条〕", type = "crime", m_qp = "zajrzxzwz", m_fly = "zajrvxvwz", qp = { "zajrzxzwz", "zajrzxzw" }, fly = { "zajrvxvwz", "zajrvxvw" } },
  { text = "阻碍军事行动罪", comment = "〔第七章 第368条〕", type = "crime", m_qp = "zajsxdz", m_fly = "zajuxdz", qp = { "zajsxdz", "zajsxd" }, fly = { "zajuxdz", "zajuxd" } },
  { text = "破坏武器装备、军事设施、军事通信罪", comment = "〔第七章 第369条〕", type = "crime", m_qp = "phwqzbjsssjstxz", m_fly = "phwqvbjuuujutxz", qp = { "phwqzbjsssjstxz", "phwqzbjsssjstx", "phwqzb", "jsss", "jstx" }, fly = { "phwqvbjuuujutxz", "phwqvbjuuujutx", "phwqvb", "juuu", "jutx" } },
  { text = "过失损坏武器装备、军事设施、军事通信罪", comment = "〔第七章 第369条〕", type = "crime", m_qp = "gsshwqzbjsssjstxz", m_fly = "gushwqvbjuuujutxz", qp = { "gsshwqzbjsssjstxz", "gsshwqzbjsssjstx", "gsshwqzb", "jsss", "jstx" }, fly = { "gushwqvbjuuujutxz", "gushwqvbjuuujutx", "gushwqvb", "juuu", "jutx" } },
  { text = "故意提供不合格武器装备、军事设施罪", comment = "〔第七章 第370条〕", type = "crime", m_qp = "gytgbhgwqzbjsssz", m_fly = "gytgbhgwqvbjuuuz", qp = { "gytgbhgwqzbjsssz", "gytgbhgwqzbjsss", "gytgbhgwqzb", "jsss" }, fly = { "gytgbhgwqvbjuuuz", "gytgbhgwqvbjuuu", "gytgbhgwqvb", "juuu" } },
  { text = "过失提供不合格武器装备、军事设施罪", comment = "〔第七章 第370条〕", type = "crime", m_qp = "gstgbhgwqzbjsssz", m_fly = "gutgbhgwqvbjuuuz", qp = { "gstgbhgwqzbjsssz", "gstgbhgwqzbjsss", "gstgbhgwqzb", "jsss" }, fly = { "gutgbhgwqvbjuuuz", "gutgbhgwqvbjuuu", "gutgbhgwqvb", "juuu" } },
  { text = "聚众冲击军事禁区罪", comment = "〔第七章 第371条〕", type = "crime", m_qp = "jzcjjsjqz", m_fly = "jvijjujqz", qp = { "jzcjjsjqz", "jzcjjsjq" }, fly = { "jvijjujqz", "jvijjujq" } },
  { text = "聚众扰乱军事管理区秩序罪", comment = "〔第七章 第371条〕", type = "crime", m_qp = "jzrljsglqzxz", m_fly = "jvrljuglqvxz", qp = { "jzrljsglqzxz", "jzrljsglqzx" }, fly = { "jvrljuglqvxz", "jvrljuglqvx" } },
  { text = "冒充军人招摇撞骗罪", comment = "〔第七章 第372条〕", type = "crime", m_qp = "mcjrzyzpz", m_fly = "mijrvyvpz", qp = { "mcjrzyzpz", "mcjrzyzp" }, fly = { "mijrvyvpz", "mijrvyvp" } },
  { text = "煽动军人逃离部队罪", comment = "〔第七章 第373条〕", type = "crime", m_qp = "sdjrtlbdz", m_fly = "udjrtlbdz", qp = { "sdjrtlbdz", "sdjrtlbd" }, fly = { "udjrtlbdz", "udjrtlbd" } },
  { text = "雇用逃离部队军人罪", comment = "〔第七章 第373条〕", type = "crime", m_qp = "gytlbdjrz", m_fly = "gytlbdjrz", qp = { "gytlbdjrz", "gytlbdjr" }, fly = { "gytlbdjrz", "gytlbdjr" } },
  { text = "接送不合格兵员罪", comment = "〔第七章 第374条〕", type = "crime", m_qp = "jsbhgbyz", m_fly = "jsbhgbyz", qp = { "jsbhgbyz", "jsbhgby" }, fly = { "jsbhgbyz", "jsbhgby" } },
  { text = "伪造、变造、买卖武装部队公文、证件、印章罪", comment = "〔第七章 第375条〕", type = "crime", m_qp = "wzbzmmwzbdgwzjyzz", m_fly = "wzbzmmwvbdgwvjyvz", qp = { "wzbzmmwzbdgwzjyzz", "wzbzmmwzbdgwzjyz", "wz", "bz", "mmwzbdgw", "zj", "yz" }, fly = { "wzbzmmwvbdgwvjyvz", "wzbzmmwvbdgwvjyv", "wz", "bz", "mmwvbdgw", "vj", "yv" } },
  { text = "盗窃、抢夺武装部队公文、证件、印章罪", comment = "〔第七章 第375条〕", type = "crime", m_qp = "dqqdwzbdgwzjyzz", m_fly = "dqqdwvbdgwvjyvz", qp = { "dqqdwzbdgwzjyzz", "dqqdwzbdgwzjyz", "dq", "qdwzbdgw", "zj", "yz" }, fly = { "dqqdwvbdgwvjyvz", "dqqdwvbdgwvjyv", "dq", "qdwvbdgw", "vj", "yv" } },
  { text = "非法生产、买卖武装部队制式服装罪", comment = "〔第七章 第375条〕", type = "crime", m_qp = "ffscmmwzbdzsfzz", m_fly = "ffuimmwvbdvufvz", qp = { "ffscmmwzbdzsfzz", "ffscmmwzbdzsfz", "ffsc", "mmwzbdzsfz" }, fly = { "ffuimmwvbdvufvz", "ffuimmwvbdvufv", "ffui", "mmwvbdvufv" } },
  { text = "伪造、盗窃、买卖、非法提供、非法使用武装部队专用标志罪", comment = "〔第七章 第375条〕", type = "crime", m_qp = "wzdqmmfftgffsywzbdzybzz", m_fly = "wzdqmmfftgffuywvbdvybvz", qp = { "wzdqmmfftgffsywzbdzybzz", "wzdqmmfftgffsywzbdzybz", "wz", "dq", "mm", "fftg", "ffsywzbdzybz" }, fly = { "wzdqmmfftgffuywvbdvybvz", "wzdqmmfftgffuywvbdvybv", "wz", "dq", "mm", "fftg", "ffuywvbdvybv" } },
  { text = "战时拒绝、逃避征召、军事训练罪", comment = "〔第七章 第376条〕", type = "crime", m_qp = "zsjjtbzzjsxlz", m_fly = "vujjtbvvjuxlz", qp = { "zsjjtbzzjsxlz", "zsjjtbzzjsxl", "zsjj", "tbzz", "jsxl" }, fly = { "vujjtbvvjuxlz", "vujjtbvvjuxl", "vujj", "tbvv", "juxl" } },
  { text = "战时拒绝、逃避服役罪", comment = "〔第七章 第376条〕", type = "crime", m_qp = "zsjjtbfyz", m_fly = "vujjtbfyz", qp = { "zsjjtbfyz", "zsjjtbfy", "zsjj", "tbfy" }, fly = { "vujjtbfyz", "vujjtbfy", "vujj", "tbfy" } },
  { text = "战时故意提供虚假敌情罪", comment = "〔第七章 第377条〕", type = "crime", m_qp = "zsgytgxjdqz", m_fly = "vugytgxjdqz", qp = { "zsgytgxjdqz", "zsgytgxjdq" }, fly = { "vugytgxjdqz", "vugytgxjdq" } },
  { text = "战时造谣扰乱军心罪", comment = "〔第七章 第378条〕", type = "crime", m_qp = "zszyrljxz", m_fly = "vuzyrljxz", qp = { "zszyrljxz", "zszyrljx" }, fly = { "vuzyrljxz", "vuzyrljx" } },
  { text = "战时窝藏逃离部队军人罪", comment = "〔第七章 第379条〕", type = "crime", m_qp = "zswctlbdjrz", m_fly = "vuwctlbdjrz", qp = { "zswctlbdjrz", "zswctlbdjr" }, fly = { "vuwctlbdjrz", "vuwctlbdjr" } },
  { text = "战时拒绝、故意延误军事订货罪", comment = "〔第七章 第380条〕", type = "crime", m_qp = "zsjjgyywjsdhz", m_fly = "vujjgyywjudhz", qp = { "zsjjgyywjsdhz", "zsjjgyywjsdh", "zsjj", "gyywjsdh" }, fly = { "vujjgyywjudhz", "vujjgyywjudh", "vujj", "gyywjudh" } },
  { text = "战时拒绝军事征收、征用罪", comment = "〔第七章 第381条〕", type = "crime", m_qp = "zsjjjszszyz", m_fly = "vujjjuvuvyz", qp = { "zsjjjszszyz", "zsjjjszszy", "zsjjjszs", "zy" }, fly = { "vujjjuvuvyz", "vujjjuvuvy", "vujjjuvu", "vy" } },
  { text = "单位受贿罪", comment = "〔第八章 第387条〕", type = "crime", m_qp = "dwshz", m_fly = "dwuhz", qp = { "dwshz", "dwsh" }, fly = { "dwuhz", "dwuh" } },
  { text = "利用影响力受贿罪", comment = "〔第八章 第388条之一〕", type = "crime", m_qp = "lyyxlshz", m_fly = "lyyxluhz", qp = { "lyyxlshz", "lyyxlsh" }, fly = { "lyyxluhz", "lyyxluh" } },
  { text = "行贿罪", comment = "〔第八章 第389条〕", type = "crime", m_qp = "xhz", m_fly = "xhz", qp = { "xhz", "xh" }, fly = { "xhz", "xh" } },
  { text = "对有影响力的人行贿罪", comment = "〔第八章 第390条之一〕", type = "crime", m_qp = "dyyxldrxhz", m_fly = "dyyxldrxhz", qp = { "dyyxldrxhz", "dyyxldrxh" }, fly = { "dyyxldrxhz", "dyyxldrxh" } },
  { text = "对单位行贿罪", comment = "〔第八章 第391条〕", type = "crime", m_qp = "ddwxhz", m_fly = "ddwxhz", qp = { "ddwxhz", "ddwxh" }, fly = { "ddwxhz", "ddwxh" } },
  { text = "介绍贿赂罪", comment = "〔第八章 第392条〕", type = "crime", m_qp = "jshlz", m_fly = "juhlz", qp = { "jshlz", "jshl" }, fly = { "juhlz", "juhl" } },
  { text = "单位行贿罪", comment = "〔第八章 第393条〕", type = "crime", m_qp = "dwxhz", m_fly = "dwxhz", qp = { "dwxhz", "dwxh" }, fly = { "dwxhz", "dwxh" } },
  { text = "巨额财产来源不明罪", comment = "〔第八章 第395条〕", type = "crime", m_qp = "jecclybmz", m_fly = "jecilybmz", qp = { "jecclybmz", "jecclybm" }, fly = { "jecilybmz", "jecilybm" } },
  { text = "隐瞒境外存款罪", comment = "〔第八章 第395条〕", type = "crime", m_qp = "ymjwckz", m_fly = "ymjwckz", qp = { "ymjwckz", "ymjwck" }, fly = { "ymjwckz", "ymjwck" } },
  { text = "私分国有资产罪", comment = "〔第八章 第396条〕", type = "crime", m_qp = "sfgyzcz", m_fly = "sfgyziz", qp = { "sfgyzcz", "sfgyzc" }, fly = { "sfgyziz", "sfgyzi" } },
  { text = "私分罚没财物罪", comment = "〔第八章 第396条〕", type = "crime", m_qp = "sffmcwz", m_fly = "sffmcwz", qp = { "sffmcwz", "sffmcw" }, fly = { "sffmcwz", "sffmcw" } },
  { text = "滥用职权罪", comment = "〔第九章 第397条〕", type = "crime", m_qp = "lyzqz", m_fly = "lyvqz", qp = { "lyzqz", "lyzq" }, fly = { "lyvqz", "lyvq" } },
  { text = "玩忽职守罪", comment = "〔第九章 第397条〕", type = "crime", m_qp = "whzsz", m_fly = "whvuz", qp = { "whzsz", "whzs" }, fly = { "whvuz", "whvu" } },
  { text = "故意泄露国家秘密罪", comment = "〔第九章 第398条〕", type = "crime", m_qp = "gyxlgjmmz", m_fly = "gyxlgjmmz", qp = { "gyxlgjmmz", "gyxlgjmm" }, fly = { "gyxlgjmmz", "gyxlgjmm" } },
  { text = "过失泄露国家秘密罪", comment = "〔第九章 第398条〕", type = "crime", m_qp = "gsxlgjmmz", m_fly = "guxlgjmmz", qp = { "gsxlgjmmz", "gsxlgjmm" }, fly = { "guxlgjmmz", "guxlgjmm" } },
  { text = "徇私枉法罪", comment = "〔第九章 第399条〕", type = "crime", m_qp = "xswfz", m_fly = "xswfz", qp = { "xswfz", "xswf" }, fly = { "xswfz", "xswf" } },
  { text = "民事、行政枉法裁判罪", comment = "〔第九章 第399条〕", type = "crime", m_qp = "msxzwfcpz", m_fly = "muxvwfcpz", qp = { "msxzwfcpz", "msxzwfcp", "ms", "xzwfcp" }, fly = { "muxvwfcpz", "muxvwfcp", "mu", "xvwfcp" } },
  { text = "执行判决、裁定失职罪", comment = "〔第九章 第399条〕", type = "crime", m_qp = "zxpjcdszz", m_fly = "vxpjcduvz", qp = { "zxpjcdszz", "zxpjcdsz", "zxpj", "cdsz" }, fly = { "vxpjcduvz", "vxpjcduv", "vxpj", "cduv" } },
  { text = "执行判决、裁定滥用职权罪", comment = "〔第九章 第399条〕", type = "crime", m_qp = "zxpjcdlyzqz", m_fly = "vxpjcdlyvqz", qp = { "zxpjcdlyzqz", "zxpjcdlyzq", "zxpj", "cdlyzq" }, fly = { "vxpjcdlyvqz", "vxpjcdlyvq", "vxpj", "cdlyvq" } },
  { text = "枉法仲裁罪", comment = "〔第九章 第399条之一〕", type = "crime", m_qp = "wfzcz", m_fly = "wfvcz", qp = { "wfzcz", "wfzc" }, fly = { "wfvcz", "wfvc" } },
  { text = "私放在押人员罪", comment = "〔第九章 第400条〕", type = "crime", m_qp = "sfzyryz", m_fly = "sfzyryz", qp = { "sfzyryz", "sfzyry" }, fly = { "sfzyryz", "sfzyry" } },
  { text = "失职致使在押人员脱逃罪", comment = "〔第九章 第400条〕", type = "crime", m_qp = "szzszyryttz", m_fly = "uvvuzyryttz", qp = { "szzszyryttz", "szzszyrytt" }, fly = { "uvvuzyryttz", "uvvuzyrytt" } },
  { text = "徇私舞弊减刑、假释、暂予监外执行罪", comment = "〔第九章 第401条〕", type = "crime", m_qp = "xswbjxjszyjwzxz", m_fly = "xswbjxjuzyjwvxz", qp = { "xswbjxjszyjwzxz", "xswbjxjszyjwzx", "xswbjx", "js", "zyjwzx" }, fly = { "xswbjxjuzyjwvxz", "xswbjxjuzyjwvx", "xswbjx", "ju", "zyjwvx" } },
  { text = "徇私舞弊不移交刑事案件罪", comment = "〔第九章 第402条〕", type = "crime", m_qp = "xswbbyjxsajz", m_fly = "xswbbyjxuajz", qp = { "xswbbyjxsajz", "xswbbyjxsaj" }, fly = { "xswbbyjxuajz", "xswbbyjxuaj" } },
  { text = "滥用管理公司、证券职权罪", comment = "〔第九章 第403条〕", type = "crime", m_qp = "lyglgszqzqz", m_fly = "lyglgsvqvqz", qp = { "lyglgszqzqz", "lyglgszqzq", "lyglgs", "zqzq" }, fly = { "lyglgsvqvqz", "lyglgsvqvq", "lyglgs", "vqvq" } },
  { text = "徇私舞弊不征、少征税款罪", comment = "〔第九章 第404条〕", type = "crime", m_qp = "xswbbzszskz", m_fly = "xswbbvuvukz", qp = { "xswbbzszskz", "xswbbzszsk", "xswbbz", "szsk" }, fly = { "xswbbvuvukz", "xswbbvuvuk", "xswbbv", "uvuk" } },
  { text = "徇私舞弊发售发票、抵扣税款、出口退税罪", comment = "〔第九章 第405条〕", type = "crime", m_qp = "xswbfsfpdkskcktsz", m_fly = "xswbfufpdkukiktuz", qp = { "xswbfsfpdkskcktsz", "xswbfsfpdkskckts", "xswbfsfp", "dksk", "ckts" }, fly = { "xswbfufpdkukiktuz", "xswbfufpdkukiktu", "xswbfufp", "dkuk", "iktu" } },
  { text = "违法提供出口退税证罪", comment = "〔第九章 第405条〕", type = "crime", m_qp = "wftgcktszz", m_fly = "wftgiktuvz", qp = { "wftgcktszz", "wftgcktsz" }, fly = { "wftgiktuvz", "wftgiktuv" } },
  { text = "国家机关工作人员签订、履行合同失职被骗罪", comment = "〔第九章 第406条〕", type = "crime", m_qp = "gjjggzryqdlxhtszbpz", m_fly = "gjjggzryqdlxhtuvbpz", qp = { "gjjggzryqdlxhtszbpz", "gjjggzryqdlxhtszbp", "gjjggzryqd", "lxhtszbp" }, fly = { "gjjggzryqdlxhtuvbpz", "gjjggzryqdlxhtuvbp", "gjjggzryqd", "lxhtuvbp" } },
  { text = "违法发放林木采伐许可证罪", comment = "〔第九章 第407条〕", type = "crime", m_qp = "wffflmcfxkzz", m_fly = "wffflmcfxkvz", qp = { "wffflmcfxkzz", "wffflmcfxkz" }, fly = { "wffflmcfxkvz", "wffflmcfxkv" } },
  { text = "环境监管失职罪", comment = "〔第九章 第408条〕", type = "crime", m_qp = "hjjgszz", m_fly = "hjjguvz", qp = { "hjjgszz", "hjjgsz" }, fly = { "hjjguvz", "hjjguv" } },
  { text = "食品、药品监管渎职罪", comment = "〔第九章 第408条之一〕", type = "crime", m_qp = "spypjgdzz", m_fly = "upypjgdvz", qp = { "spypjgdzz", "spypjgdz", "sp", "ypjgdz" }, fly = { "upypjgdvz", "upypjgdv", "up", "ypjgdv" } },
  { text = "传染病防治失职罪", comment = "〔第九章 第409条〕", type = "crime", m_qp = "crbfzszz", m_fly = "irbfvuvz", qp = { "crbfzszz", "crbfzsz" }, fly = { "irbfvuvz", "irbfvuv" } },
  { text = "非法批准征收、征用、占用土地罪", comment = "〔第九章 第410条〕", type = "crime", m_qp = "ffpzzszyzytdz", m_fly = "ffpvvuvyvytdz", qp = { "ffpzzszyzytdz", "ffpzzszyzytd", "ffpzzs", "zy", "zytd" }, fly = { "ffpvvuvyvytdz", "ffpvvuvyvytd", "ffpvvu", "vy", "vytd" } },
  { text = "非法低价出让国有土地使用权罪", comment = "〔第九章 第410条〕", type = "crime", m_qp = "ffdjcrgytdsyqz", m_fly = "ffdjirgytduyqz", qp = { "ffdjcrgytdsyqz", "ffdjcrgytdsyq" }, fly = { "ffdjirgytduyqz", "ffdjirgytduyq" } },
  { text = "放纵走私罪", comment = "〔第九章 第411条〕", type = "crime", m_qp = "fzzsz", m_fly = "fzzsz", qp = { "fzzsz", "fzzs" }, fly = { "fzzsz", "fzzs" } },
  { text = "商检徇私舞弊罪", comment = "〔第九章 第412条〕", type = "crime", m_qp = "sjxswbz", m_fly = "ujxswbz", qp = { "sjxswbz", "sjxswb" }, fly = { "ujxswbz", "ujxswb" } },
  { text = "商检失职罪", comment = "〔第九章 第412条〕", type = "crime", m_qp = "sjszz", m_fly = "ujuvz", qp = { "sjszz", "sjsz" }, fly = { "ujuvz", "ujuv" } },
  { text = "动植物检疫徇私舞弊罪", comment = "〔第九章 第413条〕", type = "crime", m_qp = "dzwjyxswbz", m_fly = "dvwjyxswbz", qp = { "dzwjyxswbz", "dzwjyxswb" }, fly = { "dvwjyxswbz", "dvwjyxswb" } },
  { text = "动植物检疫失职罪", comment = "〔第九章 第413条〕", type = "crime", m_qp = "dzwjyszz", m_fly = "dvwjyuvz", qp = { "dzwjyszz", "dzwjysz" }, fly = { "dvwjyuvz", "dvwjyuv" } },
  { text = "放纵制售伪劣商品犯罪行为罪", comment = "〔第九章 第414条〕", type = "crime", m_qp = "fzzswlspfzxwz", m_fly = "fzvuwlupfzxwz", qp = { "fzzswlspfzxwz", "fzzswlspfzxw" }, fly = { "fzvuwlupfzxwz", "fzvuwlupfzxw" } },
  { text = "办理偷越国（边）境人员出入境证件罪", comment = "〔第九章 第415条〕", type = "crime", m_qp = "bltygbjrycrjzjz", m_fly = "bltygbjryirjvjz", qp = { "bltygbjrycrjzjz", "bltygbjrycrjzj" }, fly = { "bltygbjryirjvjz", "bltygbjryirjvj" } },
  { text = "放行偷越国（边）境人员罪", comment = "〔第九章 第415条〕", type = "crime", m_qp = "fxtygbjryz", m_fly = "fxtygbjryz", qp = { "fxtygbjryz", "fxtygbjry" }, fly = { "fxtygbjryz", "fxtygbjry" } },
  { text = "不解救被拐卖、绑架妇女、儿童罪", comment = "〔第九章 第416条〕", type = "crime", m_qp = "bjjbgmbjfnetz", m_fly = "bjjbgmbjfnetz", qp = { "bjjbgmbjfnetz", "bjjbgmbjfnet", "bjjbgm", "bjfn", "et" }, fly = { "bjjbgmbjfnetz", "bjjbgmbjfnet", "bjjbgm", "bjfn", "et" } },
  { text = "阻碍解救被拐卖、绑架妇女、儿童罪", comment = "〔第九章 第416条〕", type = "crime", m_qp = "zajjbgmbjfnetz", m_fly = "zajjbgmbjfnetz", qp = { "zajjbgmbjfnetz", "zajjbgmbjfnet", "zajjbgm", "bjfn", "et" }, fly = { "zajjbgmbjfnetz", "zajjbgmbjfnet", "zajjbgm", "bjfn", "et" } },
  { text = "帮助犯罪分子逃避处罚罪", comment = "〔第九章 第417条〕", type = "crime", m_qp = "bzfzfztbcfz", m_fly = "bvfzfztbifz", qp = { "bzfzfztbcfz", "bzfzfztbcf" }, fly = { "bvfzfztbifz", "bvfzfztbif" } },
  { text = "招收公务员、学生徇私舞弊罪", comment = "〔第九章 第418条〕", type = "crime", m_qp = "zsgwyxsxswbz", m_fly = "vugwyxuxswbz", qp = { "zsgwyxsxswbz", "zsgwyxsxswb", "zsgwy", "xsxswb" }, fly = { "vugwyxuxswbz", "vugwyxuxswb", "vugwy", "xuxswb" } },
  { text = "失职造成珍贵文物损毁、流失罪", comment = "〔第九章 第419条〕", type = "crime", m_qp = "szzczgwwshlsz", m_fly = "uvzivgwwshluz", qp = { "szzczgwwshlsz", "szzczgwwshls", "szzczgwwsh", "ls" }, fly = { "uvzivgwwshluz", "uvzivgwwshlu", "uvzivgwwsh", "lu" } },
  { text = "战时违抗命令罪", comment = "〔第十章 第421条〕", type = "crime", m_qp = "zswkmlz", m_fly = "vuwkmlz", qp = { "zswkmlz", "zswkml" }, fly = { "vuwkmlz", "vuwkml" } },
  { text = "隐瞒、谎报军情罪", comment = "〔第十章 第422条〕", type = "crime", m_qp = "ymhbjqz", m_fly = "ymhbjqz", qp = { "ymhbjqz", "ymhbjq", "ym", "hbjq" }, fly = { "ymhbjqz", "ymhbjq", "ym", "hbjq" } },
  { text = "拒传、假传军令罪", comment = "〔第十章 第422条〕", type = "crime", m_qp = "jcjcjlz", m_fly = "jijijlz", qp = { "jcjcjlz", "jcjcjl", "jc", "jcjl" }, fly = { "jijijlz", "jijijl", "ji", "jijl" } },
  { text = "投降罪", comment = "〔第十章 第423条〕", type = "crime", m_qp = "txz", m_fly = "txz", qp = { "txz", "tx" }, fly = { "txz", "tx" } },
  { text = "战时临阵脱逃罪", comment = "〔第十章 第424条〕", type = "crime", m_qp = "zslzttz", m_fly = "vulvttz", qp = { "zslzttz", "zslztt" }, fly = { "vulvttz", "vulvtt" } },
  { text = "擅离、玩忽军事职守罪", comment = "〔第十章 第425条〕", type = "crime", m_qp = "slwhjszsz", m_fly = "ulwhjuvuz", qp = { "slwhjszsz", "slwhjszs", "sl", "whjszs" }, fly = { "ulwhjuvuz", "ulwhjuvu", "ul", "whjuvu" } },
  { text = "阻碍执行军事职务罪", comment = "〔第十章 第426条〕", type = "crime", m_qp = "zazxjszwz", m_fly = "zavxjuvwz", qp = { "zazxjszwz", "zazxjszw" }, fly = { "zavxjuvwz", "zavxjuvw" } },
  { text = "指使部属违反职责罪", comment = "〔第十章 第427条〕", type = "crime", m_qp = "zsbswfzzz", m_fly = "vubuwfvzz", qp = { "zsbswfzzz", "zsbswfzz" }, fly = { "vubuwfvzz", "vubuwfvz" } },
  { text = "违令作战消极罪", comment = "〔第十章 第428条〕", type = "crime", m_qp = "wlzzxjz", m_fly = "wlzvxjz", qp = { "wlzzxjz", "wlzzxj" }, fly = { "wlzvxjz", "wlzvxj" } },
  { text = "拒不救援友邻部队罪", comment = "〔第十章 第429条〕", type = "crime", m_qp = "jbjyylbdz", m_fly = "jbjyylbdz", qp = { "jbjyylbdz", "jbjyylbd" }, fly = { "jbjyylbdz", "jbjyylbd" } },
  { text = "军人叛逃罪", comment = "〔第十章 第430条〕", type = "crime", m_qp = "jrptz", m_fly = "jrptz", qp = { "jrptz", "jrpt" }, fly = { "jrptz", "jrpt" } },
  { text = "非法获取军事秘密罪", comment = "〔第十章 第431条〕", type = "crime", m_qp = "ffhqjsmmz", m_fly = "ffhqjummz", qp = { "ffhqjsmmz", "ffhqjsmm" }, fly = { "ffhqjummz", "ffhqjumm" } },
  { text = "为境外窃取、刺探、收买、非法提供军事秘密罪", comment = "〔第十章 第431条〕", type = "crime", m_qp = "wjwqqctsmfftgjsmmz", m_fly = "wjwqqctumfftgjummz", qp = { "wjwqqctsmfftgjsmmz", "wjwqqctsmfftgjsmm", "wjwqq", "ct", "sm", "fftgjsmm" }, fly = { "wjwqqctumfftgjummz", "wjwqqctumfftgjumm", "wjwqq", "ct", "um", "fftgjumm" } },
  { text = "故意泄露军事秘密罪", comment = "〔第十章 第432条〕", type = "crime", m_qp = "gyxljsmmz", m_fly = "gyxljummz", qp = { "gyxljsmmz", "gyxljsmm" }, fly = { "gyxljummz", "gyxljumm" } },
  { text = "过失泄露军事秘密罪", comment = "〔第十章 第432条〕", type = "crime", m_qp = "gsxljsmmz", m_fly = "guxljummz", qp = { "gsxljsmmz", "gsxljsmm" }, fly = { "guxljummz", "guxljumm" } },
  { text = "战时造谣惑众罪", comment = "〔第十章 第433条〕", type = "crime", m_qp = "zszyhzz", m_fly = "vuzyhvz", qp = { "zszyhzz", "zszyhz" }, fly = { "vuzyhvz", "vuzyhv" } },
  { text = "战时自伤罪", comment = "〔第十章 第434条〕", type = "crime", m_qp = "zszsz", m_fly = "vuzuz", qp = { "zszsz", "zszs" }, fly = { "vuzuz", "vuzu" } },
  { text = "逃离部队罪", comment = "〔第十章 第435条〕", type = "crime", m_qp = "tlbdz", m_fly = "tlbdz", qp = { "tlbdz", "tlbd" }, fly = { "tlbdz", "tlbd" } },
  { text = "武器装备肇事罪", comment = "〔第十章 第436条〕", type = "crime", m_qp = "wqzbzsz", m_fly = "wqvbvuz", qp = { "wqzbzsz", "wqzbzs" }, fly = { "wqvbvuz", "wqvbvu" } },
  { text = "擅自改变武器装备编配用途罪", comment = "〔第十章 第437条〕", type = "crime", m_qp = "szgbwqzbbpytz", m_fly = "uzgbwqvbbpytz", qp = { "szgbwqzbbpytz", "szgbwqzbbpyt" }, fly = { "uzgbwqvbbpytz", "uzgbwqvbbpyt" } },
  { text = "盗窃、抢夺武器装备、军用物资罪", comment = "〔第十章 第438条〕", type = "crime", m_qp = "dqqdwqzbjywzz", m_fly = "dqqdwqvbjywzz", qp = { "dqqdwqzbjywzz", "dqqdwqzbjywz", "dq", "qdwqzb", "jywz" }, fly = { "dqqdwqvbjywzz", "dqqdwqvbjywz", "dq", "qdwqvb", "jywz" } },
  { text = "非法出卖、转让武器装备罪", comment = "〔第十章 第439条〕", type = "crime", m_qp = "ffcmzrwqzbz", m_fly = "ffimvrwqvbz", qp = { "ffcmzrwqzbz", "ffcmzrwqzb", "ffcm", "zrwqzb" }, fly = { "ffimvrwqvbz", "ffimvrwqvb", "ffim", "vrwqvb" } },
  { text = "遗弃武器装备罪", comment = "〔第十章 第440条〕", type = "crime", m_qp = "yqwqzbz", m_fly = "yqwqvbz", qp = { "yqwqzbz", "yqwqzb" }, fly = { "yqwqvbz", "yqwqvb" } },
  { text = "遗失武器装备罪", comment = "〔第十章 第441条〕", type = "crime", m_qp = "yswqzbz", m_fly = "yuwqvbz", qp = { "yswqzbz", "yswqzb" }, fly = { "yuwqvbz", "yuwqvb" } },
  { text = "擅自出卖、转让军队房地产罪", comment = "〔第十章 第442条〕", type = "crime", m_qp = "szcmzrjdfdcz", m_fly = "uzimvrjdfdiz", qp = { "szcmzrjdfdcz", "szcmzrjdfdc", "szcm", "zrjdfdc" }, fly = { "uzimvrjdfdiz", "uzimvrjdfdi", "uzim", "vrjdfdi" } },
  { text = "虐待部属罪", comment = "〔第十章 第443条〕", type = "crime", m_qp = "ndbsz", m_fly = "ndbuz", qp = { "ndbsz", "ndbs" }, fly = { "ndbuz", "ndbu" } },
  { text = "遗弃伤病军人罪", comment = "〔第十章 第444条〕", type = "crime", m_qp = "yqsbjrz", m_fly = "yqubjrz", qp = { "yqsbjrz", "yqsbjr" }, fly = { "yqubjrz", "yqubjr" } },
  { text = "战时拒不救治伤病军人罪", comment = "〔第十章 第445条〕", type = "crime", m_qp = "zsjbjzsbjrz", m_fly = "vujbjvubjrz", qp = { "zsjbjzsbjrz", "zsjbjzsbjr" }, fly = { "vujbjvubjrz", "vujbjvubjr" } },
  { text = "战时残害居民、掠夺居民财物罪", comment = "〔第十章 第446条〕", type = "crime", m_qp = "zschjmldjmcwz", m_fly = "vuchjmldjmcwz", qp = { "zschjmldjmcwz", "zschjmldjmcw", "zschjm", "ldjmcw" }, fly = { "vuchjmldjmcwz", "vuchjmldjmcw", "vuchjm", "ldjmcw" } },
  { text = "私放俘虏罪", comment = "〔第十章 第447条〕", type = "crime", m_qp = "sfflz", m_fly = "sfflz", qp = { "sfflz", "sffl" }, fly = { "sfflz", "sffl" } },
  { text = "虐待俘虏罪", comment = "〔第十章 第448条〕", type = "crime", m_qp = "ndflz", m_fly = "ndflz", qp = { "ndflz", "ndfl" }, fly = { "ndflz", "ndfl" } },
}

require("legal_full_pinyin_data").apply(M.records)

function M.search(query, is_flypy)
  local flypy_mode = (is_flypy == true or is_flypy == "flypy")
  local key_field = flypy_mode and "m_fly" or "m_qp"
  local keys_field = flypy_mode and "fly" or "qp"

  if not query or query == "" then
    local res = {}
    local seen = {}
    local common_texts = {
      "故意杀人罪", "抢劫罪", "盗窃罪", "诈骗罪", "危险驾驶罪",
      "交通肇事罪", "受贿罪", "贪污罪", "职务侵占罪", "袭警罪",
      "寻衅滋事罪", "非法吸收公众存款罪", "帮信罪", "网络诈骗",
      "危害公共安全罪", "侵犯财产罪"
    }
    for _, ct in ipairs(common_texts) do
      for _, r in ipairs(M.records) do
        if (r.text == ct or r.text:find(ct, 1, true)) and not seen[r.text] then
          seen[r.text] = true
          table.insert(res, {
            text = r.text,
            comment = r.comment,
            code = r[key_field],
            type = r.type
          })
          break
        end
      end
    end
    -- Also include top chapters for empty A
    for _, r in ipairs(M.records) do
      if r.type == "chapter_full" and not seen[r.text] then
        seen[r.text] = true
        table.insert(res, {
          text = r.text,
          comment = r.comment,
          code = r[key_field],
          type = r.type
        })
        if #res >= 12 then break end
      end
    end
    return res
  end

  query = query:lower()

  local exact_results = {}
  local prefix_results = {}
  local substr_results = {}
  local seen = {}

  for _, rec in ipairs(M.records) do
    local all_keys = rec[keys_field]
    local m_k = rec[key_field]
    local text = rec.text

    -- 1. 精确匹配
    local is_exact = false
    for _, k in ipairs(all_keys) do
      if k == query then
        is_exact = true
        break
      end
    end

    if is_exact then
      if not seen[text] then
        seen[text] = true
        table.insert(exact_results, {
          text = text,
          comment = rec.comment,
          code = m_k,
          type = rec.type,
          is_exact = true,
          key_len = #m_k
        })
      end
    else
      -- 2. 前缀匹配
      local is_prefix = false
      for _, k in ipairs(all_keys) do
        if #k >= #query and k:sub(1, #query) == query then
          is_prefix = true
          break
        end
      end

      if is_prefix then
        if not seen[text] then
          seen[text] = true
          table.insert(prefix_results, {
            text = text,
            comment = rec.comment,
            code = m_k,
            type = rec.type,
            is_exact = false,
            key_len = #m_k
          })
        end
      else
        -- 3. 子串包含筛选
        local best_pos = nil
        for _, k in ipairs(all_keys) do
          local pos = k:find(query, 1, true)
          if pos then
            if not best_pos or pos < best_pos then
              best_pos = pos
            end
          end
        end

        if best_pos then
          if not seen[text] then
            seen[text] = true
            table.insert(substr_results, {
              text = text,
              comment = rec.comment,
              code = m_k,
              type = rec.type,
              is_exact = false,
              key_len = #m_k,
              pos = best_pos
            })
          end
        end
      end
    end
  end

  -- 前缀排序：短键优先
  table.sort(prefix_results, function(a, b)
    if a.key_len ~= b.key_len then
      return a.key_len < b.key_len
    end
    return false
  end)

  -- 子串排序：位置靠前优先，次之短键优先
  table.sort(substr_results, function(a, b)
    if a.pos ~= b.pos then
      return a.pos < b.pos
    end
    if a.key_len ~= b.key_len then
      return a.key_len < b.key_len
    end
    return false
  end)

  local final_results = {}
  for _, item in ipairs(exact_results) do
    table.insert(final_results, item)
  end
  for _, item in ipairs(prefix_results) do
    table.insert(final_results, item)
  end
  for _, item in ipairs(substr_results) do
    table.insert(final_results, item)
  end

  -- 4. 若无匹配，执行多词块组合切分筛选（方案A：如 gysr, wxjs 等）
  if #final_results == 0 and #query >= 3 then
    local partition_results = {}
    local p_seen = {}

    local function check_tokens(tokens)
      for _, rec in ipairs(M.records) do
        local all_k = rec[keys_field]
        local all_found = true
        local sum_pos = 0

        for _, tok in ipairs(tokens) do
          local tok_found = false
          local best_t_pos = 999
          for _, k in ipairs(all_k) do
            local p = k:find(tok, 1, true)
            if p then
              tok_found = true
              if p < best_t_pos then best_t_pos = p end
            end
          end
          if not tok_found then
            all_found = false
            break
          end
          sum_pos = sum_pos + best_t_pos
        end

        if all_found and not p_seen[rec.text] then
          p_seen[rec.text] = true
          local m_k = rec[key_field]
          table.insert(partition_results, {
            text = rec.text,
            comment = rec.comment,
            code = m_k,
            type = rec.type,
            is_exact = false,
            key_len = #m_k,
            pos = sum_pos
          })
        end
      end
    end

    if query:find("'", 1, true) then
      local tokens = {}
      for part in query:gmatch("[^']+") do
        if #part > 0 then table.insert(tokens, part) end
      end
      if #tokens > 0 then check_tokens(tokens) end
    else
      local len = #query
      for cut = 2, len - 1 do
        local tok1 = query:sub(1, cut)
        local tok2 = query:sub(cut + 1)
        if (#tok1 >= 2 and #tok2 >= 2) or (#tok1 >= 3 and #tok2 >= 1) or (#tok1 >= 1 and #tok2 >= 3) then
          check_tokens({tok1, tok2})
        end
      end

      if #partition_results == 0 and len >= 6 then
        for c1 = 2, len - 3 do
          for c2 = c1 + 2, len - 1 do
            local tok1 = query:sub(1, c1)
            local tok2 = query:sub(c1 + 1, c2)
            local tok3 = query:sub(c2 + 1)
            if #tok1 >= 2 and #tok2 >= 2 and #tok3 >= 1 then
              check_tokens({tok1, tok2, tok3})
            end
          end
        end
      end
    end

    table.sort(partition_results, function(a, b)
      if a.key_len ~= b.key_len then
        return a.key_len < b.key_len
      end
      if a.pos ~= b.pos then
        return a.pos < b.pos
      end
      return false
    end)

    for _, item in ipairs(partition_results) do
      table.insert(final_results, item)
    end
  end

  return final_results
end

return M
